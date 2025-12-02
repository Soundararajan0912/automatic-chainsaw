# Azure Log Analytics Workspace Module

This module creates an Azure Log Analytics Workspace for monitoring and logging.

## Usage

```hcl
module "log_analytics" {
  source              = "./log-analytics-workspace"
  name                = "law-prod-eastus-001"
  location            = "eastus"
  resource_group_name = "rg-prod-eastus-001"
  sku                 = "PerGB2018"
  retention_in_days   = 90
  daily_quota_gb      = 10
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Common Integrations

- **AKS clusters**: Pass `module.log_analytics.id` into the `log_analytics_workspace_id` input of the `aks` module to enable Container Insights.
- **Container Apps Environment**: Provide the workspace ID to collect application and platform logs.
- **Azure Monitor agents**: Reference the workspace ID when configuring VM extensions or diagnostic settings for other Azure resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the Log Analytics workspace | string | n/a | yes |
| location | Azure region where the Log Analytics workspace will be created | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| sku | SKU of the Log Analytics workspace | string | "PerGB2018" | no |
| retention_in_days | Retention period in days (30-730) | number | 30 | no |
| daily_quota_gb | Daily ingestion limit in GB (-1 for no limit) | number | -1 | no |
| tags | Tags to apply to the Log Analytics workspace | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Log Analytics workspace |
| name | The name of the Log Analytics workspace |
| workspace_id | The workspace ID of the Log Analytics workspace |
| primary_shared_key | The primary shared key for the Log Analytics workspace (sensitive) |
