# Azure Storage Container Module

Creates a blob container within an existing Azure Storage Account, including optional metadata, encryption scope enforcement, and immutability policies.

## Usage

```hcl
module "storage_container" {
  source               = "./container"
  name                 = "app-artifacts"
  storage_account_name = module.storage_account.name
  container_access_type = "private"

  metadata = {
    Environment = "Production"
    Purpose     = "Artifacts"
  }

  immutability_policy = {
    state                                     = "Unlocked"
    immutability_period_since_creation_in_days = 30
    allow_protected_append_writes             = true
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the storage container | string | n/a | yes |
| storage_account_name | Name of the parent storage account | string | n/a | yes |
| container_access_type | Access level of the container (blob, container, private) | string | "private" | no |
| metadata | Metadata key/value pairs | map(string) | {} | no |
| default_encryption_scope | Default encryption scope for the container | string | null | no |
| prevent_encryption_scope_override | Prevent objects from specifying a different encryption scope | bool | false | no |
| immutability_policy | Optional immutability policy configuration | object | null | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the storage container |
| name | The name of the storage container |
| resource_manager_id | The resource manager ID of the storage container |
