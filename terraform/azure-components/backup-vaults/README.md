# Azure Backup Vault Module

This module creates an Azure Backup Vault (Data Protection) with optional backup policies for disks and blob storage.

## Usage

```hcl
module "backup_vault" {
  source              = "./backup-vaults"
  name                = "bv-prod-eastus-001"
  location            = "eastus"
  resource_group_name = "rg-prod-eastus-001"
  datastore_type      = "VaultStore"
  redundancy          = "GeoRedundant"
  
  # Disk backup policy
  create_disk_policy             = true
  disk_backup_intervals          = ["R/2024-01-01T00:00:00+00:00/PT4H"]
  disk_default_retention_duration = "P7D"
  
  # Blob backup policy
  create_blob_policy      = true
  blob_retention_duration = "P30D"
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

## Important Notes

- This module uses Azure Data Protection (modern backup solution)
- The backup vault gets a system-assigned managed identity
- Backup intervals use ISO 8601 duration format (e.g., PT4H = every 4 hours)
- Retention durations use ISO 8601 duration format (e.g., P7D = 7 days, P30D = 30 days)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the backup vault | string | n/a | yes |
| location | Azure region where the backup vault will be created | string | n/a | yes |
| resource_group_name | Name of the resource group | string | n/a | yes |
| datastore_type | Datastore type (VaultStore, ArchiveStore, OperationalStore) | string | "VaultStore" | no |
| redundancy | Redundancy level (LocallyRedundant, GeoRedundant, ZoneRedundant) | string | "GeoRedundant" | no |
| create_disk_policy | Create a disk backup policy | bool | false | no |
| disk_backup_intervals | Backup intervals for disk policy | list(string) | ["R/2024-01-01T00:00:00+00:00/PT4H"] | no |
| disk_default_retention_duration | Default retention duration for disk backups | string | "P7D" | no |
| create_blob_policy | Create a blob storage backup policy | bool | false | no |
| blob_retention_duration | Retention duration for blob backups | string | "P30D" | no |
| tags | Tags to apply to the backup vault | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the backup vault |
| name | The name of the backup vault |
| principal_id | The principal ID of the system-assigned managed identity |
| disk_policy_id | The ID of the disk backup policy |
| blob_policy_id | The ID of the blob storage backup policy |
