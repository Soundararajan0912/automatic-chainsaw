# Simple Azure Infrastructure Example
# This example shows basic usage of core modules

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
  features {}
}

# Create a resource group
module "resource_group" {
  source   = "../resource-group"
  name     = "rg-dev-eastus-001"
  location = "eastus"
  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

# Create a virtual network
module "vnet" {
  source              = "../vnet"
  name                = "vnet-dev-eastus-001"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet
module "subnet" {
  source               = "../subnet"
  name                 = "snet-dev-web-001"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a storage account
module "storage" {
  source                   = "../storage-account"
  name                     = "stdeveastus001"
  resource_group_name      = module.resource_group.name
  location                 = module.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

# Outputs
output "resource_group_name" {
  value = module.resource_group.name
}

output "vnet_id" {
  value = module.vnet.id
}

output "subnet_id" {
  value = module.subnet.id
}

output "storage_account_name" {
  value = module.storage.name
}
