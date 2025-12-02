# Azure Network Security Group Module

This module creates an Azure Network Security Group with configurable security rules.

## Usage

```hcl
module "nsg" {
  source              = "./nsg"
  name                = "nsg-prod-web-001"
  location            = "eastus"
  resource_group_name = "rg-prod-eastus-001"
  security_rules = [
    {
      name                       = "AllowHTTPS"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHTTP"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    }
  ]
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the network security group | string | n/a | yes |
| location | Azure region where the NSG will be created | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| security_rules | List of security rules to create | list(object) | [] | no |
| tags | Tags to apply to the NSG | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the network security group |
| name | The name of the network security group |
