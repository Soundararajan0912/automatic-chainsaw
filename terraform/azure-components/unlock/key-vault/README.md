# Key Vault Unlock Module

Removes an existing management lock from a Key Vault via the shared `unlock` module.

## Usage

```hcl
module "keyvault_unlock" {
  source       = "../unlock/key-vault"
  key_vault_id = module.key_vault.id
  lock_name    = "lock-keyvault-prod"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| lock_name | Name of the Key Vault lock to remove | string | "lock-keyvault" | no |
| key_vault_id | Resource ID of the Key Vault | string | n/a | yes |
| force_reapply | Toggle to force rerunning the unlock action | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| lock_name | The lock removed from the Key Vault |
| scope | Key Vault scope where the lock was removed |
