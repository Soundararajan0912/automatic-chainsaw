variable "resource_group_name" {
  type        = string
  description = "Resource group where all resources except the shared VNet live."
}

variable "location" {
  type        = string
  description = "Azure region for all deployed resources."
}

variable "virtual_network_id" {
  type        = string
  description = "Resource ID of the existing virtual network hosting both subnets."
}

variable "container_app_subnet_id" {
  type        = string
  description = "Resource ID of the delegated subnet for Azure Container Apps (Microsoft.App/environments)."
}

variable "app_gateway_subnet_id" {
  type        = string
  description = "Resource ID of the dedicated subnet for Application Gateway."
}

variable "name_prefix" {
  type        = string
  description = "Base prefix used when generating resource names. Non-alphanumeric characters are stripped."
  default     = "aca-appgw"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags applied to all managed resources."
  default     = {}
}

variable "enable_https" {
  type        = bool
  description = "Set to true to create HTTPS listener and require certificate inputs."
  default     = false
}

variable "public_hostname" {
  type        = string
  description = "Public FQDN that clients use (e.g., app.example.com). Leave null for catch-all listener."
  default     = null

  validation {
    #condition     = var.public_hostname == null ? true : can(regex("^(?=.{1,253}$)(?!-)(?:[a-zA-Z0-9-]{1,63}\\.)+[a-zA-Z]{2,}$", var.public_hostname))
    condition  = var.public_hostname == null ? true : can(regex("\\.[A-Za-z0-9-]{2,}$", var.public_hostname))
    error_message = "public_hostname must be a valid DNS name such as app.example.com."
  }
}

variable "public_ip_dns_label" {
  type        = string
  description = "Optional public IP DNS label (creates <label>.<region>.cloudapp.azure.com). Must be globally unique."
  default     = null

  validation {
    condition     = var.public_ip_dns_label == null ? true : can(regex("^[a-z0-9-]{3,63}$", var.public_ip_dns_label))
    error_message = "public_ip_dns_label must be 3-63 characters of lowercase letters, numbers, or hyphens."
  }
}

variable "gateway_certificate_data" {
  type        = string
  description = "Base64-encoded PFX certificate used by Application Gateway for HTTPS listener (required when enable_https = true)."
  default     = null

  validation {
    condition = var.enable_https ? can(base64decode(var.gateway_certificate_data)) : true
    error_message = "gateway_certificate_data must be provided as valid base64 when enable_https is true."
  }
}

variable "gateway_certificate_password" {
  type        = string
  description = "Password for the uploaded PFX certificate (required when enable_https = true)."
  sensitive   = true
  default     = null

  validation {
    condition     = var.enable_https ? (var.gateway_certificate_password != null && length(var.gateway_certificate_password) > 0) : true
    error_message = "gateway_certificate_password cannot be empty when enable_https is true."
  }
}

variable "app_gateway_sku_name" {
  type        = string
  description = "Application Gateway SKU name (Standard_v2 or WAF_v2)."
  default     = "Standard_v2"
}

variable "app_gateway_sku_tier" {
  type        = string
  description = "Application Gateway SKU tier (Standard_v2 or WAF_v2)."
  default     = "Standard_v2"
}

variable "app_gateway_autoscale_min" {
  type        = number
  description = "Minimum number of Application Gateway instances for autoscale."
  default     = 1

  validation {
    condition     = var.app_gateway_autoscale_min >= 1
    error_message = "app_gateway_autoscale_min must be at least 1."
  }
}

variable "app_gateway_autoscale_max" {
  type        = number
  description = "Maximum number of Application Gateway instances for autoscale."
  default     = 2

  validation {
    condition     = var.app_gateway_autoscale_max >= var.app_gateway_autoscale_min
    error_message = "app_gateway_autoscale_max must be greater than or equal to app_gateway_autoscale_min."
  }
}

variable "enable_waf" {
  type        = bool
  description = "Set to true to enable WAF_v2 configuration. Requires WAF_v2 SKU."
  default     = false

  validation {
    condition     = var.enable_waf ? var.app_gateway_sku_tier == "WAF_v2" && var.app_gateway_sku_name == "WAF_v2" : true
    error_message = "enable_waf can only be true when both app_gateway_sku_name and tier are set to WAF_v2."
  }
}

variable "waf_firewall_mode" {
  type        = string
  description = "WAF firewall mode (Prevention or Detection)."
  default     = "Prevention"

  validation {
    condition     = contains(["Prevention", "Detection"], var.waf_firewall_mode)
    error_message = "waf_firewall_mode must be either Prevention or Detection."
  }
}

variable "waf_rule_set_version" {
  type        = string
  description = "OWASP rule set version when WAF is enabled."
  default     = "3.2"
}

variable "container_app_transport" {
  type        = string
  description = "Ingress transport for Container Apps (auto, http, or tcp)."
  default     = "auto"

  validation {
    condition     = contains(["auto", "http", "tcp"], lower(var.container_app_transport))
    error_message = "container_app_transport must be one of auto, http, or tcp."
  }
}

variable "container_app_backend_protocol" {
  type        = string
  description = "Protocol used by Application Gateway when calling the Container Apps environment."
  default     = "Https"

  validation {
    condition     = contains(["Http", "Https"], var.container_app_backend_protocol)
    error_message = "container_app_backend_protocol must be either Http or Https (case-sensitive)."
  }
}

variable "container_app_backend_port" {
  type        = number
  description = "Port used by Application Gateway when connecting to Container Apps ingress (typically 443)."
  default     = 443

  validation {
    condition     = var.container_app_backend_port > 0 && var.container_app_backend_port <= 65535
    error_message = "container_app_backend_port must be between 1 and 65535."
  }
}

variable "default_min_replicas" {
  type        = number
  description = "Minimum replica count for each container app."
  default     = 1

  validation {
    condition     = var.default_min_replicas >= 0
    error_message = "default_min_replicas must be zero or greater."
  }
}

variable "default_max_replicas" {
  type        = number
  description = "Maximum replica count for each container app."
  default     = 3

  validation {
    condition     = var.default_max_replicas >= var.default_min_replicas
    error_message = "default_max_replicas must be greater than or equal to default_min_replicas."
  }
}

variable "default_container_cpu" {
  type        = number
  description = "Default CPU requested for each container (in cores)."
  default     = 0.5
}

variable "default_container_memory" {
  type        = string
  description = "Default memory requested for each container (e.g., 1Gi)."
  default     = "1Gi"
}

variable "container_apps" {
  type = list(object({
    name        = string
    image       = string
    target_port = number
    path        = optional(string)
    is_default  = optional(bool, false)
    cpu         = optional(number)
    memory      = optional(string)
    health_path = optional(string)
  }))

  description = "Definitions for each container app, including routing paths and container configuration. Exactly one entry must set is_default = true."

  default = [
    {
      name        = "app1"
      image       = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      target_port = 80
      path        = "/"
      is_default  = true
      health_path = "/"
    },
    {
      name        = "app2"
      image       = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      target_port = 80
      path        = "/app2/*"
      health_path = "/"
    },
    {
      name        = "app3"
      image       = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      target_port = 80
      path        = "/app3/*"
      health_path = "/"
    }
  ]

  validation {
    condition     = length([for app in var.container_apps : app if try(app.is_default, false)]) == 1
    error_message = "Exactly one container app must be marked as is_default = true."
  }

  validation {
    condition = alltrue([
      for app in var.container_apps :
      try(app.is_default, false) ? true : (try(app.path, "") != "" && can(regex("^/", app.path)))
    ])
    error_message = "Every non-default container app must define a path that starts with '/'."
  }

  validation {
    condition = alltrue([
      for app in var.container_apps :
      app.target_port > 0 && app.target_port <= 65535
    ])
    error_message = "Each container app target_port must be between 1 and 65535."
  }
}
