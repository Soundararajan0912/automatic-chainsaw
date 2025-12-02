# Azure Key Vault Module

This module creates an Azure Key Vault with configurable access policies and network rules.

## Usage

```hcl
module "key_vault" {
  source              = "./key vault"
  name                = "kv-prod-eastus-001"
  location            = "eastus"
  resource_group_name = "rg-prod-eastus-001"
  sku_name            = "standard"
  
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  
  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = ["203.0.113.0/24"]
    virtual_network_subnet_ids = ["/subscriptions/.../subnets/subnet-id"]
  }
  
  access_policies = [
    {
      object_id = "00000000-0000-0000-0000-000000000000"
      key_permissions = ["Get", "List", "Create"]
      secret_permissions = ["Get", "List", "Set"]
      certificate_permissions = ["Get", "List"]
    }
  ]
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the key vault (must be globally unique, 3-24 characters) | string | n/a | yes |
| location | Azure region where the key vault will be created | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| sku_name | SKU name for the key vault (standard or premium) | string | "standard" | no |
| soft_delete_retention_days | Number of days to retain soft-deleted key vault | number | 90 | no |
| purge_protection_enabled | Enable purge protection | bool | true | no |
| enabled_for_disk_encryption | Enable key vault for disk encryption | bool | false | no |
| enabled_for_deployment | Enable key vault for VM deployment | bool | false | no |
| enabled_for_template_deployment | Enable key vault for ARM template deployment | bool | false | no |
| network_acls | Network ACLs for the key vault | object | null | no |
| access_policies | Access policies for the key vault | list(object) | [] | no |
| tags | Tags to apply to the key vault | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the key vault |
| name | The name of the key vault |
| vault_uri | The URI of the key vault |
