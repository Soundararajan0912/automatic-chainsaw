# Complete Azure Infrastructure Example
# This example demonstrates how to use multiple modules together to provision a complete infrastructure

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

# Variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureadmin"
}

# Local values for consistent naming
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "CompanyInfra"
    CostCenter  = "IT"
  }
}

# 1. Resource Group
module "resource_group" {
  source   = "../resource-group"
  name     = "rg-${var.environment}-${var.location}-001"
  location = var.location
  tags     = local.common_tags
}

# 2. Log Analytics Workspace (for monitoring)
module "log_analytics" {
  source              = "../log-analytics-workspace"
  name                = "law-${var.environment}-${var.location}-001"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  tags                = local.common_tags
}

# 3. Virtual Network
module "vnet" {
  source              = "../vnet"
  name                = "vnet-${var.environment}-${var.location}-001"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = []
  tags                = local.common_tags
}

# 4. Subnets
module "aks_subnet" {
  source               = "../subnet"
  name                 = "snet-aks-001"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
}

module "appgw_subnet" {
  source               = "../subnet"
  name                 = "snet-appgw-001"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = []
}

module "vm_subnet" {
  source               = "../subnet"
  name                 = "snet-vm-001"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

# 5. Network Security Groups
module "aks_nsg" {
  source              = "../nsg"
  name                = "nsg-aks-001"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  security_rules = [
    {
      name                       = "AllowHTTPS"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
  tags = local.common_tags
}

# 6. Managed Identity
module "aks_identity" {
  source              = "../managed-identity"
  name                = "mi-aks-${var.environment}-001"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  tags                = local.common_tags
}

# 7. Azure Container Registry
module "acr" {
  source              = "../acr"
  name                = "acr${var.environment}${replace(var.location, "-", "")}001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  sku                 = "Premium"
  admin_enabled       = false
  tags                = local.common_tags
}

# 8. Azure Kubernetes Service
module "aks" {
  source              = "../aks"
  name                = "aks-${var.environment}-${var.location}-001"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  dns_prefix          = "aks${var.environment}"
  kubernetes_version  = "1.28"

  default_node_pool = {
    name                = "default"
    node_count          = 3
    vm_size             = "Standard_D4s_v3"
    vnet_subnet_id      = module.aks_subnet.id
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 10
    max_pods            = 110
    os_disk_size_gb     = 128
  }

  identity_type = "UserAssigned"
  identity_ids  = [module.aks_identity.id]

  network_profile = {
    network_plugin    = "azure"
    network_policy    = "calico"
    dns_service_ip    = "10.1.0.10"
    service_cidr      = "10.1.0.0/16"
    load_balancer_sku = "standard"
  }

  log_analytics_workspace_id = module.log_analytics.id
  tags                       = local.common_tags
}

# 9. Key Vault
module "key_vault" {
  source              = "../key vault"
  name                = "kv-${var.environment}-${substr(var.location, 0, 4)}-001"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  sku_name            = "standard"

  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = [module.aks_subnet.id, module.vm_subnet.id]
  }

  tags = local.common_tags
}

# 10. Storage Account
module "storage_account" {
  source              = "../storage-account"
  name                = "st${var.environment}${replace(var.location, "-", "")}001"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  account_tier        = "Standard"
  account_replication_type = "GRS"

  network_rules = {
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = [module.aks_subnet.id, module.vm_subnet.id]
    bypass                     = ["AzureServices"]
  }

  tags = local.common_tags
}

# 11. Application Gateway
module "app_gateway" {
  source              = "../app-gw"
  name                = "agw-${var.environment}-${var.location}-001"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  sku_name            = "Standard_v2"
  sku_tier            = "Standard_v2"
  capacity            = 2
  subnet_id           = module.appgw_subnet.id
  tags                = local.common_tags
}

# 12. Backup Vault
module "backup_vault" {
  source              = "../backup-vaults"
  name                = "bv-${var.environment}-${var.location}-001"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  redundancy          = "GeoRedundant"

  create_disk_policy             = true
  disk_default_retention_duration = "P7D"

  tags = local.common_tags
}

# 13. Resource Locks (for critical resources)
module "keyvault_lock" {
  source     = "../lock"
  name       = "lock-prevent-delete"
  scope      = module.key_vault.id
  lock_level = "CanNotDelete"
  notes      = "Prevents accidental deletion of production key vault"
}

module "aks_lock" {
  source     = "../lock"
  name       = "lock-prevent-delete"
  scope      = module.aks.id
  lock_level = "CanNotDelete"
  notes      = "Prevents accidental deletion of production AKS cluster"
}

# Outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = module.aks.name
}

output "acr_login_server" {
  description = "The login server URL for ACR"
  value       = module.acr.login_server
}

output "key_vault_uri" {
  description = "The URI of the key vault"
  value       = module.key_vault.vault_uri
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.storage_account.name
}

output "app_gateway_public_ip" {
  description = "The public IP of the application gateway"
  value       = module.app_gateway.public_ip_address
}
