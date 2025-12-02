# Application Gateway Lock Module

Creates an Azure management lock that targets an Application Gateway to prevent accidental deletion or modification.

## Usage

```hcl
module "app_gateway_lock" {
  source          = "../lock/app-gw"
  name            = "lock-appgw-prod"
  app_gateway_id  = module.app_gateway.id
  lock_level      = "CanNotDelete"
  notes           = "Protects production Application Gateway"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the management lock | string | n/a | yes |
| app_gateway_id | Resource ID of the Application Gateway | string | n/a | yes |
| lock_level | Lock level (CanNotDelete or ReadOnly) | string | n/a | yes |
| notes | Optional notes about the lock | string | null | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Application Gateway lock |
| name | The name of the Application Gateway lock |
