# Azure Container App Environment Module

This module creates an Azure Container App Environment for hosting container apps.

## Usage

```hcl
module "container_app_env" {
  source                     = "./container-app-env"
  name                       = "cae-prod-eastus-001"
  location                   = "eastus"
  resource_group_name        = "rg-prod-eastus-001"
  log_analytics_workspace_id = "/subscriptions/.../workspaces/law-id"
  infrastructure_subnet_id   = "/subscriptions/.../subnets/container-subnet"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Important Notes

- Log Analytics workspace is required for monitoring
- If using VNet integration, the infrastructure subnet must be delegated to `Microsoft.App/environments`
- The subnet must have a minimum size of /23 for VNet integration
- Only the subnet resource ID is needed; the module does not require direct VNet inputs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the container app environment | string | n/a | yes |
| location | Azure region where the container app environment will be created | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| log_analytics_workspace_id | ID of the Log Analytics workspace for monitoring | string | n/a | yes |
| infrastructure_subnet_id | ID of the subnet for infrastructure (optional, for VNet integration) | string | null | no |
| tags | Tags to apply to the container app environment | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the container app environment |
| name | The name of the container app environment |
| default_domain | The default domain of the container app environment |
| static_ip_address | The static IP address of the container app environment |
