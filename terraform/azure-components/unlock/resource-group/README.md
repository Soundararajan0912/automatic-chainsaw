# Resource Group Unlock Module

Wrapper around the generic `unlock` module that removes a management lock from a specific resource group.

## Usage

```hcl
module "rg_unlock" {
  source            = "../unlock/resource-group"
  resource_group_id = module.resource_group.id
  lock_name         = "lock-prevent-delete"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| lock_name | Name of the resource group lock to remove | string | "lock-prevent-delete" | no |
| resource_group_id | Resource ID of the target resource group | string | n/a | yes |
| force_reapply | Toggle to force rerunning the unlock action | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| lock_name | The lock removed from the resource group |
| scope | Resource group scope where the lock was removed |
