# Per-Service Budget Module

Creates a subscription-level Cost Management budget filtered to one or more Azure services.

## Usage

```hcl
module "compute_budget" {
  source          = "../cost-management/per service"
  name            = "budget-compute-prod"
  subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000000"
  service_names   = ["Microsoft.Compute/virtualMachines"]
  amount          = 8000
  time_grain      = "Monthly"
  time_period = {
    start_date = "2025-01-01T00:00:00Z"
    end_date   = "2025-12-31T00:00:00Z"
  }

  notifications = {
    Actual75 = {
      operator       = "GreaterThan"
      threshold      = 75
      threshold_type = "Actual"
      contact_emails = ["compute-owner@example.com"]
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the per-service budget | string | n/a | yes |
| subscription_id | Subscription ID | string | n/a | yes |
| service_names | List of Azure service names to include | list(string) | n/a | yes |
| amount | Budget amount | number | n/a | yes |
| time_grain | Time grain (Monthly, Quarterly, Annually) | string | "Monthly" | no |
| time_period | Budget start/end dates | object | n/a | yes |
| notifications | Notification configuration map | map(object) | see variables.tf | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the per-service budget |
| name | The name of the per-service budget |
