# Subscription Budget Module

Creates a Cost Management budget scoped to a subscription and configures alerts for spend or forecast thresholds.

## Usage

```hcl
module "subscription_budget" {
  source          = "../cost-management/subscription"
  name            = "budget-subscription-prod"
  subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
  amount          = 25000
  time_grain      = "Monthly"
  time_period = {
    start_date = "2025-01-01T00:00:00Z"
    end_date   = "2025-12-31T00:00:00Z"
  }

  notifications = {
    Forecast90 = {
      operator       = "GreaterThan"
      threshold      = 90
      threshold_type = "Forecasted"
      contact_emails = ["finops@example.com"]
    }
    Actual100 = {
      operator       = "GreaterThan"
      threshold      = 100
      threshold_type = "Actual"
      contact_emails = ["cloudops@example.com"]
      contact_roles  = ["Owner"]
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the subscription budget | string | n/a | yes |
| subscription_id | Subscription ID | string | n/a | yes |
| amount | Budget amount | number | n/a | yes |
| time_grain | Time grain (Monthly, Quarterly, Annually) | string | "Monthly" | no |
| time_period | Budget start/end dates | object | n/a | yes |
| notifications | Notification configuration map | map(object) | see variables.tf | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the subscription budget |
| name | The name of the subscription budget |
