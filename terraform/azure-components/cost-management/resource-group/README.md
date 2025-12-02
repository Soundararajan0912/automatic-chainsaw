# Resource Group Budget Module

Creates a Cost Management budget scoped to a resource group with optional tag-based filters.

## Usage

```hcl
module "rg_budget" {
  source            = "../cost-management/resource-group"
  name              = "budget-rg-aks"
  resource_group_id = module.resource_group.id
  amount            = 5000
  time_grain        = "Monthly"
  time_period = {
    start_date = "2025-01-01T00:00:00Z"
    end_date   = "2025-12-31T00:00:00Z"
  }

  tag_filters = [
    {
      name     = "Environment"
      operator = "In"
      values   = ["Production"]
    }
  ]

  notifications = {
    Actual80 = {
      operator       = "GreaterThan"
      threshold      = 80
      threshold_type = "Actual"
      contact_emails = ["owner@example.com"]
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the resource group budget | string | n/a | yes |
| resource_group_id | ID of the resource group | string | n/a | yes |
| amount | Budget amount | number | n/a | yes |
| time_grain | Time grain (Monthly, Quarterly, Annually) | string | "Monthly" | no |
| time_period | Budget time period | object | n/a | yes |
| tag_filters | Optional tag-based filters | list(object) | [] | no |
| notifications | Notification configuration map | map(object) | see variables.tf | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the resource group budget |
| name | The name of the resource group budget |
