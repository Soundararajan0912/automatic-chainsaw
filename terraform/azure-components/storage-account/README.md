# Azure Storage Account Module

This module creates an Azure Storage Account with configurable network rules and security settings.

## Usage

```hcl
module "storage_account" {
  source              = "./storage-account"
  name                = "stprodeastus001"
  resource_group_name = "rg-prod-eastus-001"
  location            = "eastus"
  account_tier        = "Standard"
  account_replication_type = "GRS"
  account_kind        = "StorageV2"
  access_tier         = "Hot"
  
  network_rules = {
    default_action             = "Deny"
    ip_rules                   = ["203.0.113.0/24"]
    virtual_network_subnet_ids = ["/subscriptions/.../subnets/subnet-id"]
    bypass                     = ["AzureServices"]
  }
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the storage account (must be globally unique, 3-24 characters, lowercase alphanumeric) | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| location | Azure region where the storage account will be created | string | n/a | yes |
| account_tier | Storage account tier (Standard or Premium) | string | "Standard" | no |
| account_replication_type | Storage account replication type | string | "LRS" | no |
| account_kind | Storage account kind | string | "StorageV2" | no |
| access_tier | Access tier for the storage account (Hot or Cool) | string | "Hot" | no |
| min_tls_version | Minimum TLS version | string | "TLS1_2" | no |
| enable_https_traffic_only | Enable HTTPS traffic only | bool | true | no |
| allow_nested_items_to_be_public | Allow nested items to be public | bool | false | no |
| network_rules | Network rules for the storage account | object | null | no |
| tags | Tags to apply to the storage account | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the storage account |
| name | The name of the storage account |
| primary_blob_endpoint | The primary blob endpoint |
| primary_access_key | The primary access key (sensitive) |
| primary_connection_string | The primary connection string (sensitive) |
