variable "subscription_id" {
  description = "Azure subscription ID to target for resource deployment."
  type        = string
  default     = "07512706-3bc2-4200-9b89-5bce3249bddb"
}

variable "resource_group_name" {
  description = "Name of the resource group to create or manage."
  type        = string
  default     = "soundar-rnd-01"
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "eastus"
}

variable "vnet_address_space" {
  description = "CIDR block for the primary virtual network."
  type        = string
  default     = "10.0.0.0/24"
}

variable "subnet_prefixes" {
  description = "Map of subnet names to explicit CIDR ranges inside the VNet."
  type        = map(string)
  default = {
    AppGatewaySubnet      = "10.0.0.0/28"
    VMSubnet              = "10.0.0.16/28"
    ContainerAppsSubnet   = "10.0.0.32/25"
    PrivateEndpointsSubnet = "10.0.0.160/27"
    FutureBufferSubnet    = "10.0.0.192/27"
  }

  validation {
    condition     = alltrue([for cidr in values(var.subnet_prefixes) : can(cidrhost(cidr, 0))])
    error_message = "All subnet CIDRs must be valid IPv4 CIDR blocks."
  }
}

variable "nat_subnet_names" {
  description = "Subnet names that should receive the NAT gateway association."
  type        = list(string)
  default     = ["AppGatewaySubnet", "ContainerAppsSubnet", "VMSubnet", "PrivateEndpointsSubnet", "FutureBufferSubnet"]

  validation {
    condition     = alltrue([for name in var.nat_subnet_names : contains(keys(var.subnet_prefixes), name)])
    error_message = "All NAT subnet names must also appear in subnet_prefixes."
  }
}

variable "vm_subnet_name" {
  description = "Subnet name (from subnet_prefixes) that will host the private VM."
  type        = string
  default     = "VMSubnet"

  validation {
    condition     = contains(keys(var.subnet_prefixes), var.vm_subnet_name)
    error_message = "vm_subnet_name must exist in subnet_prefixes."
  }
}

variable "vm_size" {
  description = "Azure VM size."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_os_disk_size_gb" {
  description = "OS disk size in GiB for the VM."
  type        = number
  default     = 130
}

variable "vm_encryption_at_host_enabled" {
  description = "Enable host-based encryption for VM disks."
  type        = bool
  default     = true
}

variable "assign_vm_identity_key_vault_access" {
  description = "Whether to grant the VM's managed identity RBAC access to the Key Vault."
  type        = bool
  default     = true
}

variable "vm_key_vault_role_definition_name" {
  description = "Role definition name used when granting the VM's managed identity access to the Key Vault."
  type        = string
  default     = "Key Vault Administrator"
}

variable "admin_username" {
  description = "Admin username for the VM."
  type        = string
  default     = "soundar-rnd-01"
}

variable "admin_password" {
  description = "Admin password for the VM (used for serial console access)."
  type        = string
  sensitive   = true
}

variable "computer_name" {
  description = "Hostname that will be assigned to the VM."
  type        = string
  default     = "soundarvm"
}

variable "custom_image_id" {
  description = "Resource ID of the custom Shared Image Gallery version to use for the VM."
  type        = string
}

variable "nginx_server_name" {
  description = "Server name to configure inside the nginx site definition."
  type        = string
  default     = "dev.example.com"
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault to create."
  type        = string
  default     = "soundar-keyvault"
}

variable "key_vault_sku_name" {
  description = "SKU for the Key Vault (e.g., standard, premium)."
  type        = string
  default     = "standard"
}

variable "key_vault_default_action" {
  description = "Default action for the Key Vault firewall. Keep 'Deny' during normal operation; temporarily set to 'Allow' for troubleshooting."
  type        = string
  default     = "Deny"

  validation {
    condition     = contains(["Deny", "Allow"], var.key_vault_default_action)
    error_message = "key_vault_default_action must be either 'Deny' or 'Allow'."
  }
}

variable "key_vault_allowed_ip_rules" {
  description = "Optional list of CIDR blocks (IPv4) that should be allowed through the Key Vault firewall so Terraform or trusted operators outside the VNet can reach data-plane APIs during deployment."
  type        = list(string)
  default     = []
}

variable "app_gateway_name" {
  description = "Name of the Application Gateway to create."
  type        = string
  default     = "soundar-appgw"
}

variable "app_gateway_subnet_name" {
  description = "Name of the subnet (from subnet_prefixes) dedicated to the Application Gateway."
  type        = string
  default     = "AppGatewaySubnet"
}

variable "app_gateway_capacity" {
  description = "Scale unit for the Application Gateway instance."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
  default = {
    environment = "dev"
    owner       = "soundar"
  }
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace that stores monitoring data."
  type        = string
  default     = "soundar-law-dev"
}

variable "log_analytics_workspace_sku" {
  description = "SKU for the Log Analytics workspace (e.g., PerGB2018)."
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_workspace_retention_days" {
  description = "Number of days to retain data inside the Log Analytics workspace."
  type        = number
  default     = 30
}

variable "data_collection_rule_name" {
  description = "Name of the Azure Monitor data collection rule for the VM."
  type        = string
  default     = "soundar-vm-dcr"
}

variable "azure_monitor_agent_extension_name" {
  description = "Name to assign to the Azure Monitor Agent VM extension."
  type        = string
  default     = "soundar-ama-ext"
}

variable "dependency_agent_extension_name" {
  description = "Name to assign to the Dependency (VM Insights map) agent extension."
  type        = string
  default     = "soundar-dependency-ext"
}

variable "enable_dependency_agent_extension" {
  description = "Whether to deploy the legacy Dependency Agent extension (Service Map). Leave false on Ubuntu 24.04+ where Microsoft has not published a supported build."
  type        = bool
  default     = false
}

variable "vm_backup_vault_name" {
  description = "Name of the Recovery Services vault that stores VM backups."
  type        = string
  default     = "soundar-backup-vault"
}

variable "vm_backup_policy_name" {
  description = "Name of the VM backup policy (daily schedule)."
  type        = string
  default     = "soundar-vm-daily"
}

variable "vm_backup_daily_time" {
  description = "UTC time (HH:MM) when the daily VM backup should run."
  type        = string
  default     = "22:00"
}

variable "vm_backup_retention_days" {
  description = "Number of days to retain daily VM backups."
  type        = number
  default     = 7
}

variable "vm_delete_lock_name" {
  description = "Name of the management lock applied to the VM to prevent accidental deletion."
  type        = string
  default     = "soundarvm-delete-lock"
}

variable "storage_account_delete_lock_name" {
  description = "Name of the delete lock applied to the storage account."
  type        = string
  default     = "storage-delete-lock"
}

variable "acr_delete_lock_name" {
  description = "Name of the delete lock applied to the Azure Container Registry."
  type        = string
  default     = "acr-delete-lock"
}

variable "app_gateway_delete_lock_name" {
  description = "Name of the delete lock applied to the Application Gateway."
  type        = string
  default     = "appgw-delete-lock"
}

variable "key_vault_data_plane_assignee_object_id" {
  description = "Object ID of the principal (user, service principal, or managed identity) that should receive data-plane access to the Key Vault. Leave blank to skip." 
  type        = string
  default     = ""
}

variable "key_vault_data_plane_role_definition_name" {
  description = "Built-in role name to assign for Key Vault data-plane access (e.g., 'Key Vault Secrets Officer', 'Key Vault Administrator')."
  type        = string
  default     = "Key Vault Secrets Officer"
}

variable "key_vault_data_plane_principal_type" {
  description = "Principal type for the data-plane role assignment (User, ServicePrincipal, Group, ForeignGroup)."
  type        = string
  default     = "User"
}

variable "storage_account_name" {
  description = "Globally unique name for the storage account that will store application backups."
  type        = string
  default     = "soundarstorageacct"
}

variable "storage_account_tier" {
  description = "Performance tier for the storage account (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "Replication type for the storage account (e.g., LRS, GRS)."
  type        = string
  default     = "LRS"
}

variable "storage_account_container_name" {
  description = "Name of the blob container used to store application backups."
  type        = string
  default     = "app-backups"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique and lowercase)."
  type        = string
  default     = "soundaracrdev"
}

variable "acr_sku" {
  description = "SKU of the ACR (Premium required for advanced features)."
  type        = string
  default     = "Premium"
}

variable "acr_retention_days" {
  description = "Lifecycle retention in days for untagged manifests (approximates keeping last N revisions)."
  type        = number
  default     = 7
}
