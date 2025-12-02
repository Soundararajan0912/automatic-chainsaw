# Azure Application Gateway Module

This module creates an Azure Application Gateway with a public IP and basic configuration.

## Usage

```hcl
module "app_gateway" {
  source              = "./app-gw"
  name                = "agw-prod-eastus-001"
  location            = "eastus"
  resource_group_name = "rg-prod-eastus-001"
  sku_name            = "Standard_v2"
  sku_tier            = "Standard_v2"
  capacity            = 2
  subnet_id           = "/subscriptions/.../subnets/appgw-subnet"
  backend_address_pool_name = "backend-pool"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Important Notes

- The Application Gateway subnet must be dedicated to the Application Gateway only
- The subnet must have a minimum size of /27
- This module creates a basic configuration with HTTP listener on port 80
- For production use, consider adding HTTPS listeners with SSL certificates

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the application gateway | string | n/a | yes |
| location | Azure region where the application gateway will be created | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| sku_name | SKU name | string | "Standard_v2" | no |
| sku_tier | SKU tier | string | "Standard_v2" | no |
| capacity | Capacity (instance count) of the application gateway | number | 2 | no |
| subnet_id | ID of the subnet where the application gateway will be deployed | string | n/a | yes |
| backend_address_pool_name | Name of the backend address pool | string | "backend-pool" | no |
| tags | Tags to apply to the application gateway | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the application gateway |
| name | The name of the application gateway |
| public_ip_address | The public IP address of the application gateway |
| backend_address_pool_id | The ID of the backend address pool |
