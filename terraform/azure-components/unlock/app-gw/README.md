# Application Gateway Unlock Module

Removes an existing management lock from an Application Gateway by reusing the shared `unlock` module.

## Usage

```hcl
module "app_gateway_unlock" {
  source         = "../unlock/app-gw"
  app_gateway_id = module.app_gateway.id
  lock_name      = "lock-appgw-prod"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| lock_name | Name of the Application Gateway lock to remove | string | "lock-appgw" | no |
| app_gateway_id | Resource ID of the Application Gateway | string | n/a | yes |
| force_reapply | Toggle to force rerunning the unlock action | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| lock_name | The lock removed from the Application Gateway |
| scope | Application Gateway scope where the lock was removed |
