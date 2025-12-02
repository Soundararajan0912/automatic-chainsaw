# Key Vault Lock Module

Creates an Azure management lock that targets a Key Vault to prevent accidental deletion or modification.

## Usage

```hcl
module "key_vault_lock" {
  source       = "../lock/key-vault"
  name         = "lock-keyvault-prod"
  key_vault_id = module.key_vault.id
  lock_level   = "CanNotDelete"
  notes        = "Protects production Key Vault"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the management lock | string | n/a | yes |
| key_vault_id | Resource ID of the Key Vault | string | n/a | yes |
| lock_level | Lock level (CanNotDelete or ReadOnly) | string | n/a | yes |
| notes | Optional notes about the lock | string | null | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Key Vault lock |
| name | The name of the Key Vault lock |
