# Azure Container Registry Module

This module creates an Azure Container Registry with support for geo-replication and network rules.

## Usage

```hcl
module "acr" {
  source              = "./acr"
  name                = "acrprodeastus001"
  resource_group_name = "rg-prod-eastus-001"
  location            = "eastus"
  sku                 = "Premium"
  admin_enabled       = false
  
  georeplications = [
    {
      location                = "westus"
      zone_redundancy_enabled = true
      tags                    = {}
    }
  ]
  
  network_rule_set = {
    default_action             = "Deny"
    ip_rules                   = ["203.0.113.0/24"]
    virtual_network_subnet_ids = ["/subscriptions/.../subnets/subnet-id"]
  }
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the container registry (must be globally unique, alphanumeric, 5-50 characters) | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| location | Azure region where the container registry will be created | string | n/a | yes |
| sku | SKU of the container registry (Basic, Standard, Premium) | string | "Standard" | no |
| admin_enabled | Enable admin user | bool | false | no |
| georeplications | Geo-replication configuration (Premium SKU only) | list(object) | [] | no |
| network_rule_set | Network rule set for the container registry | object | null | no |
| tags | Tags to apply to the container registry | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the container registry |
| name | The name of the container registry |
| login_server | The login server URL of the container registry |
| admin_username | The admin username of the container registry |
| admin_password | The admin password of the container registry (sensitive) |
