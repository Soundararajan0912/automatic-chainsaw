# Azure Virtual Network Module

This module creates an Azure Virtual Network with configurable address space and DNS servers.

## Usage

```hcl
module "vnet" {
  source              = "./vnet"
  name                = "vnet-prod-eastus-001"
  location            = "eastus"
  resource_group_name = "rg-prod-eastus-001"
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the virtual network | string | n/a | yes |
| location | Azure region where the virtual network will be created | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| address_space | Address space for the virtual network | list(string) | n/a | yes |
| dns_servers | List of DNS servers for the virtual network | list(string) | [] | no |
| tags | Tags to apply to the virtual network | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the virtual network |
| name | The name of the virtual network |
| address_space | The address space of the virtual network |
| location | The location of the virtual network |
