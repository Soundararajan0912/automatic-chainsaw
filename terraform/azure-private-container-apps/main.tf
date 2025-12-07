terraform {
  required_version = ">= 1.5.0"
 
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.113"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
 
provider "azurerm" {
  features {}
}
 
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}
 
locals {
  sanitized_prefix   = replace(lower(var.name_prefix), "[^a-z0-9]", "")
  normalized_prefix  = length(trimspace(local.sanitized_prefix)) > 0 ? local.sanitized_prefix : "aca"
  unique_suffix     = random_string.suffix.result
  common_tags       = merge({ "managed-by" = "terraform" }, var.tags)
 
  container_apps_by_name = { for app in var.container_apps : app.name => app }
  default_app_name       = tolist([for app in var.container_apps : app.name if try(app.is_default, false)])[0]
  non_default_apps       = [for app in var.container_apps : app if app.name != local.default_app_name]
 
  log_analytics_name = substr("${local.normalized_prefix}law${local.unique_suffix}", 0, 62)
  env_name           = "${local.normalized_prefix}-env-${local.unique_suffix}"
  public_ip_name     = "${local.normalized_prefix}-pip-${local.unique_suffix}"
  app_gateway_name   = "${local.normalized_prefix}-agw-${local.unique_suffix}"
}
 
resource "azurerm_log_analytics_workspace" "main" {
  name                = local.log_analytics_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.common_tags
}
 
resource "azurerm_container_app_environment" "internal" {
  name                            = local.env_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  log_analytics_workspace_id      = azurerm_log_analytics_workspace.main.id
  infrastructure_subnet_id        = var.container_app_subnet_id
  internal_load_balancer_enabled  = true
  tags                            = local.common_tags
}
 
resource "azurerm_container_app" "app" {
  for_each = local.container_apps_by_name
 
  name                         = each.value.name
  container_app_environment_id = azurerm_container_app_environment.internal.id
  resource_group_name          = var.resource_group_name
  #location                     = var.location
  revision_mode                = "Single"
  tags                         = local.common_tags
 
  ingress {
    external_enabled = false
    target_port      = each.value.target_port
    transport        = lower(var.container_app_transport)
 
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
 
  template {
    min_replicas = var.default_min_replicas
    max_replicas = var.default_max_replicas
 
    container {
      name   = each.value.name
      image  = each.value.image
      cpu    = coalesce(each.value.cpu, var.default_container_cpu)
      memory = coalesce(each.value.memory, var.default_container_memory)
    }
  }
}
 
resource "azurerm_private_dns_zone" "container_apps" {
  name                = azurerm_container_app_environment.internal.default_domain
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}
 
resource "azurerm_private_dns_a_record" "wildcard" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.container_apps.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_container_app_environment.internal.static_ip_address]
}
 
resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "link-${local.unique_suffix}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.container_apps.name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
}
 
resource "azurerm_public_ip" "app_gateway" {
  name                = local.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.public_ip_dns_label
  tags                = local.common_tags
}
 
locals {
  backend_configs = { for name, app in azurerm_container_app.app :
    name => {
      fqdn        = "${name}.${azurerm_container_app_environment.internal.default_domain}"
      target_port = local.container_apps_by_name[name].target_port
      health_path = lookup(local.container_apps_by_name[name], "health_path", "/")
    }
  }
}
 
resource "azurerm_application_gateway" "main" {
  name                = local.app_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  enable_http2        = true
  tags                = local.common_tags
 
  sku {
    name = var.app_gateway_sku_name
    tier = var.app_gateway_sku_tier
  }
 
  autoscale_configuration {
    min_capacity = var.app_gateway_autoscale_min
    max_capacity = var.app_gateway_autoscale_max
  }
 
  gateway_ip_configuration {
    name      = "gw-ip-config"
    subnet_id = var.app_gateway_subnet_id
  }
 
  frontend_port {
    name = "port-80"
    port = 80
  }
 
  frontend_port {
    name = "port-443"
    port = 443
  }
 
  frontend_ip_configuration {
    name                 = "public-frontend"
    public_ip_address_id = azurerm_public_ip.app_gateway.id
  }
 
  dynamic "backend_address_pool" {
    for_each = local.backend_configs
    content {
      name  = "bp-${backend_address_pool.key}"
      fqdns = [backend_address_pool.value.fqdn]
    }
  }
 
  dynamic "probe" {
    for_each = local.backend_configs
    content {
      name                                      = "probe-${probe.key}"
      protocol                                  = var.container_app_backend_protocol
      path                                      = probe.value.health_path
      port                                      = var.container_app_backend_port
      interval                                  = 30
      timeout                                   = 30
      unhealthy_threshold                       = 3
      pick_host_name_from_backend_http_settings = true
      match {
        status_code = ["200-410"]
      }
    }
  }
 
  dynamic "backend_http_settings" {
    for_each = local.backend_configs
    content {
      name                                = "https-${backend_http_settings.key}"
      protocol                            = var.container_app_backend_protocol
      port                                = var.container_app_backend_port
      cookie_based_affinity               = "Disabled"
      request_timeout                     = 30
      pick_host_name_from_backend_address = false
      host_name                           = backend_http_settings.value.fqdn
      probe_name                          = "probe-${backend_http_settings.key}"
    }
  }
 
  http_listener {
    name                           = "listener-http"
    frontend_ip_configuration_name = "public-frontend"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
    host_name                      = var.public_hostname
  }
 
  dynamic "http_listener" {
    for_each = var.enable_https ? [1] : []
    content {
      name                           = "listener-https"
      frontend_ip_configuration_name = "public-frontend"
      frontend_port_name             = "port-443"
      protocol                       = "Https"
      host_name                      = var.public_hostname
      ssl_certificate_name           = "gateway-cert"
    }
  }
 
  dynamic "ssl_certificate" {
    for_each = var.enable_https ? [1] : []
    content {
      name     = "gateway-cert"
      data     = var.gateway_certificate_data
      password = var.gateway_certificate_password
    }
  }
 
  // Use a supported TLS policy to avoid deprecated versions
  ssl_policy {
    policy_type          = "Predefined"
    policy_name          = "AppGwSslPolicy20220101"
    min_protocol_version = "TLSv1_2"
  }
 
  url_path_map {
    name                               = "apps-path-map"
    default_backend_address_pool_name  = "bp-${local.default_app_name}"
    default_backend_http_settings_name = "https-${local.default_app_name}"
 
    dynamic "path_rule" {
      for_each = { for app in local.non_default_apps : app.name => app }
      content {
        name                       = "rule-${path_rule.key}"
        paths                      = [path_rule.value.path]
        backend_address_pool_name  = "bp-${path_rule.key}"
        backend_http_settings_name = "https-${path_rule.key}"
      }
    }
  }
 
  request_routing_rule {
    name               = "rule-http"
    rule_type          = "PathBasedRouting"
    http_listener_name = "listener-http"
    url_path_map_name  = "apps-path-map"
    priority           = 100
  }
 
  dynamic "request_routing_rule" {
    for_each = var.enable_https ? [1] : []
    content {
      name               = "rule-https"
      rule_type          = "PathBasedRouting"
      http_listener_name = "listener-https"
      url_path_map_name  = "apps-path-map"
      priority           = 101
    }
  }
 
  dynamic "waf_configuration" {
    for_each = var.enable_waf ? [1] : []
    content {
      enabled          = true
      firewall_mode    = var.waf_firewall_mode
      rule_set_type    = "OWASP"
      rule_set_version = var.waf_rule_set_version
    }
  }
 
  depends_on = [azurerm_private_dns_zone_virtual_network_link.link]
}