locals {
  subnet_cidr_map = var.subnet_prefixes
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  vnet_address_space  = var.vnet_address_space
  subnet_map          = local.subnet_cidr_map
  nat_subnet_names    = var.nat_subnet_names
  app_gateway_subnet_name = var.app_gateway_subnet_name
  tags                = var.tags
}

module "compute" {
  source = "./modules/compute"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  subnet_id           = module.network.subnet_ids[var.vm_subnet_name]
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  vm_size             = var.vm_size
  vm_os_disk_size_gb  = var.vm_os_disk_size_gb
  encryption_at_host_enabled = var.vm_encryption_at_host_enabled
  custom_image_id     = var.custom_image_id
  computer_name       = var.computer_name
  nginx_server_name   = var.nginx_server_name
  tags                = var.tags
}

resource "azurerm_key_vault" "this" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.this.location
  resource_group_name         = azurerm_resource_group.this.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = lower(var.key_vault_sku_name)
  rbac_authorization_enabled  = true
  enabled_for_deployment      = true
  enabled_for_template_deployment = true
  enabled_for_disk_encryption = true

  network_acls {
    bypass                     = "AzureServices"
    default_action             = var.key_vault_default_action
    virtual_network_subnet_ids = values(module.network.subnet_ids)
    ip_rules                   = var.key_vault_allowed_ip_rules
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "key_vault_vm_identity" {
  count = var.assign_vm_identity_key_vault_access ? 1 : 0

  scope                = azurerm_key_vault.this.id
  role_definition_name = var.vm_key_vault_role_definition_name
  principal_id         = module.compute.identity_principal_id
}

resource "azurerm_role_assignment" "key_vault_data_plane" {
  count = var.key_vault_data_plane_assignee_object_id == "" ? 0 : 1

  scope                = azurerm_key_vault.this.id
  role_definition_name = var.key_vault_data_plane_role_definition_name
  principal_id         = var.key_vault_data_plane_assignee_object_id
  principal_type       = var.key_vault_data_plane_principal_type
}

resource "azurerm_public_ip" "app_gateway" {
  name                = "${var.app_gateway_name}-pip"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "this" {
  name                = var.app_gateway_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  depends_on          = [module.network]

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = var.app_gateway_capacity
  }

  gateway_ip_configuration {
    name      = "appgw-ipcfg"
    subnet_id = module.network.subnet_ids[var.app_gateway_subnet_name]
  }

  frontend_port {
    name = "appgw-fe-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appgw-fe-ip"
    public_ip_address_id = azurerm_public_ip.app_gateway.id
  }

  backend_address_pool {
    name         = "appgw-backend-pool"
    ip_addresses = [module.compute.private_ip]
  }

  backend_http_settings {
    name                  = "appgw-backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "appgw-http-listener"
    frontend_ip_configuration_name = "appgw-fe-ip"
    frontend_port_name             = "appgw-fe-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "appgw-http-rule"
    rule_type                  = "Basic"
    http_listener_name         = "appgw-http-listener"
    backend_address_pool_name  = "appgw-backend-pool"
    backend_http_settings_name = "appgw-backend-http-settings"
    priority                   = 100
  }

  tags = var.tags
}

resource "azurerm_management_lock" "app_gateway_delete" {
  name       = var.app_gateway_delete_lock_name
  scope      = azurerm_application_gateway.this.id
  lock_level = "CanNotDelete"
  notes      = "Protects the application gateway from accidental deletion."
}

resource "azurerm_storage_account" "backups" {
  name                     = lower(var.storage_account_name)
  location                 = azurerm_resource_group.this.location
  resource_group_name      = azurerm_resource_group.this.name
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  allow_nested_items_to_be_public = false
  min_tls_version          = "TLS1_2"
  public_network_access_enabled = true
  identity {
    type = "SystemAssigned"
  }

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "backups" {
  name                  = var.storage_account_container_name
  storage_account_id    = azurerm_storage_account.backups.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "vm_storage_blob_contributor" {
  scope                = azurerm_storage_account.backups.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.compute.identity_principal_id
}

resource "azurerm_management_lock" "storage_delete" {
  name       = var.storage_account_delete_lock_name
  scope      = azurerm_storage_account.backups.id
  lock_level = "CanNotDelete"
  notes      = "Protects the backup storage account from accidental deletion."
}

resource "azurerm_container_registry" "this" {
  name                = lower(var.acr_name)
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = var.acr_sku
  admin_enabled       = false
  public_network_access_enabled = true
  tags = var.tags
}

resource "azurerm_role_assignment" "acr_vm_identity" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPush"
  principal_id         = module.compute.identity_principal_id
}

resource "azurerm_management_lock" "acr_delete" {
  name       = var.acr_delete_lock_name
  scope      = azurerm_container_registry.this.id
  lock_level = "CanNotDelete"
  notes      = "Protects the container registry from accidental deletion."
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_workspace_retention_days
  tags                = var.tags
}

resource "azurerm_log_analytics_solution" "vminsights" {
  solution_name        = "VMInsights"
  location             = azurerm_resource_group.this.location
  resource_group_name  = azurerm_resource_group.this.name
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  workspace_name       = azurerm_log_analytics_workspace.this.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/VMInsights"
  }

  depends_on = [azurerm_log_analytics_workspace.this]
}

resource "azurerm_monitor_data_collection_rule" "vm" {
  name                = var.data_collection_rule_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  kind                = "Linux"
  description         = "Collects performance counters, syslog, docker, and nginx logs from the VM."

  data_sources {
    performance_counter {
      name                          = "linux-perf-counters"
      streams                       = ["Microsoft-Perf", "Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\Processor(_Total)\\% Processor Time",
        "\\Processor(_Total)\\% Privileged Time",
        "\\Memory\\Available MBytes",
        "\\Memory\\% Used Memory",
        "\\LogicalDisk(_Total)\\% Free Space",
        "\\LogicalDisk(_Total)\\Disk Reads/sec",
        "\\LogicalDisk(_Total)\\Disk Writes/sec",
        "\\NetworkInterface(*)\\Bytes Total/sec"
      ]
    }

    syslog {
      name           = "linux-syslog"
      streams        = ["Microsoft-Syslog"]
      facility_names = ["auth", "authpriv", "cron", "daemon", "kern", "syslog", "user", "local0", "local1", "local2", "local3", "local4", "local5", "local6", "local7"]
      log_levels     = ["Debug", "Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
    }

  }

  destinations {
    log_analytics {
      name                  = "log-analytics-default"
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
    }

    azure_monitor_metrics {
      name = "metrics-store"
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf"]
    destinations = ["log-analytics-default"]
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics"]
    destinations = ["metrics-store"]
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["log-analytics-default"]
  }

  tags = var.tags

  depends_on = [
    azurerm_log_analytics_solution.vminsights
  ]
}

resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  name                       = var.azure_monitor_agent_extension_name
  virtual_machine_id         = module.compute.vm_id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.27"
  auto_upgrade_minor_version = true
  settings                   = jsonencode({})
  tags                       = var.tags
}

resource "azurerm_virtual_machine_extension" "dependency_agent" {
  count                      = var.enable_dependency_agent_extension ? 1 : 0
  name                       = var.dependency_agent_extension_name
  virtual_machine_id         = module.compute.vm_id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = "9.10"
  auto_upgrade_minor_version = true
  tags                       = var.tags
}

resource "azurerm_monitor_data_collection_rule_association" "vm" {
  name                    = "${var.data_collection_rule_name}-assoc"
  target_resource_id      = module.compute.vm_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.vm.id
  depends_on              = [azurerm_virtual_machine_extension.azure_monitor_agent]
}

resource "azurerm_recovery_services_vault" "vm" {
  name                = var.vm_backup_vault_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"
  soft_delete_enabled = true
  tags                = var.tags
}

resource "azurerm_backup_policy_vm" "daily" {
  name                = var.vm_backup_policy_name
  resource_group_name = azurerm_resource_group.this.name
  recovery_vault_name = azurerm_recovery_services_vault.vm.name
  policy_type         = "V1"

  backup {
    frequency = "Daily"
    time      = var.vm_backup_daily_time
  }

  retention_daily {
    count = var.vm_backup_retention_days
  }
}

resource "azurerm_backup_protected_vm" "vm" {
  resource_group_name = azurerm_resource_group.this.name
  recovery_vault_name = azurerm_recovery_services_vault.vm.name
  source_vm_id        = module.compute.vm_id
  backup_policy_id    = azurerm_backup_policy_vm.daily.id
}

resource "azurerm_management_lock" "vm_delete" {
  name       = var.vm_delete_lock_name
  scope      = module.compute.vm_id
  lock_level = "CanNotDelete"
  notes      = "Prevents accidental deletion of the VM."
}
