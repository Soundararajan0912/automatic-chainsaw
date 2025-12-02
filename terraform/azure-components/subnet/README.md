# Azure Subnet Module

This module creates an Azure Subnet with support for service endpoints and delegations.

## Usage

```hcl
module "subnet" {
  source               = "./subnet"
  name                 = "snet-prod-web-001"
  resource_group_name  = "rg-prod-eastus-001"
  virtual_network_name = "vnet-prod-eastus-001"
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"]
  delegations = [
    {
      name         = "aks-delegation"
      service_name = "Microsoft.ContainerService/managedClusters"
      actions      = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the subnet | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| virtual_network_name | Name of the virtual network | string | n/a | yes |
| address_prefixes | Address prefixes for the subnet | list(string) | n/a | yes |
| service_endpoints | List of service endpoints to enable on the subnet | list(string) | [] | no |
| delegations | Subnet delegations configuration | list(object) | [] | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the subnet |
| name | The name of the subnet |
| address_prefixes | The address prefixes of the subnet |
