# Azure Managed Identity Module

This module creates an Azure User-Assigned Managed Identity.

## Usage

```hcl
module "managed_identity" {
  source              = "./managed-identity"
  name                = "mi-prod-aks-001"
  location            = "eastus"
  resource_group_name = "rg-prod-eastus-001"
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the managed identity | string | n/a | yes |
| location | Azure region where the managed identity will be created | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| tags | Tags to apply to the managed identity | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the managed identity |
| name | The name of the managed identity |
| principal_id | The principal ID of the managed identity |
| client_id | The client ID of the managed identity |
