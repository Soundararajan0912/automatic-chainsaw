# Azure Management Lock Module

This module creates an Azure Management Lock to prevent accidental deletion or modification of resources.

## Usage

### Lock on Application Gateway
```hcl
module "appgw_lock" {
  source     = "../lock"
  name       = "lock-prevent-delete"
  scope      = module.app_gateway.id
  lock_level = "CanNotDelete"
  notes      = "Prevents accidental deletion of production application gateway"
}
```

### Lock on Key Vault
```hcl
module "keyvault_lock" {
  source     = "../lock"
  name       = "lock-prevent-delete"
  scope      = module.key_vault.id
  lock_level = "CanNotDelete"
  notes      = "Prevents accidental deletion of production key vault"
}
```

### Lock on Virtual Machine
```hcl
module "vm_lock" {
  source     = "../lock"
  name       = "lock-read-only"
  scope      = module.vm.id
  lock_level = "ReadOnly"
  notes      = "Prevents any modifications to production VM"
}
```

## Lock Levels

- **CanNotDelete**: Authorized users can read and modify a resource, but they can't delete it
- **ReadOnly**: Authorized users can read a resource, but they can't delete or update it

## Important Notes

- Locks apply to all users and roles
- To modify or delete a locked resource, you must first remove the lock
- Locks are inherited by child resources
- The scope parameter accepts any resource ID

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the management lock | string | n/a | yes |
| scope | The scope at which the lock applies (resource ID) | string | n/a | yes |
| lock_level | Lock level (CanNotDelete or ReadOnly) | string | n/a | yes |
| notes | Notes about the lock | string | null | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the management lock |
| name | The name of the management lock |
