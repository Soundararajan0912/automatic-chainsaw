variable "name" {
  description = "Name of the key vault (must be globally unique, 3-24 characters)"
  type        = string
}

variable "location" {
  description = "Azure region where the key vault will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "sku_name" {
  description = "SKU name for the key vault (standard or premium)"
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted key vault"
  type        = number
  default     = 90
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = true
}

variable "enabled_for_disk_encryption" {
  description = "Enable key vault for disk encryption"
  type        = bool
  default     = false
}

variable "enabled_for_deployment" {
  description = "Enable key vault for VM deployment"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Enable key vault for ARM template deployment"
  type        = bool
  default     = false
}

variable "network_acls" {
  description = "Network ACLs for the key vault"
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  default = null
}

variable "access_policies" {
  description = "Access policies for the key vault"
  type = list(object({
    object_id               = string
    key_permissions         = list(string)
    secret_permissions      = list(string)
    certificate_permissions = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the key vault"
  type        = map(string)
  default     = {}
}
