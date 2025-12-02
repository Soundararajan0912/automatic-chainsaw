# Azure Resource Group Module

This module creates an Azure Resource Group with configurable tags.

## Usage

```hcl
module "resource_group" {
  source   = "./resource-group"
  name     = "rg-prod-eastus-001"
  location = "eastus"
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    CostCenter  = "IT"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the resource group | string | n/a | yes |
| location | Azure region where the resource group will be created | string | n/a | yes |
| tags | Tags to apply to the resource group | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the resource group |
| name | The name of the resource group |
| location | The location of the resource group |
