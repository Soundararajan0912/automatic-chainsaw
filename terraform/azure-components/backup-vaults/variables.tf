variable "name" {
  description = "Name of the backup vault"
  type        = string
}

variable "location" {
  description = "Azure region where the backup vault will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "datastore_type" {
  description = "Datastore type (VaultStore, ArchiveStore, OperationalStore)"
  type        = string
  default     = "VaultStore"
}

variable "redundancy" {
  description = "Redundancy level (LocallyRedundant, GeoRedundant, ZoneRedundant)"
  type        = string
  default     = "GeoRedundant"
}

variable "create_disk_policy" {
  description = "Create a disk backup policy"
  type        = bool
  default     = false
}

variable "disk_backup_intervals" {
  description = "Backup intervals for disk policy (e.g., ['R/2024-01-01T00:00:00+00:00/PT4H'])"
  type        = list(string)
  default     = ["R/2024-01-01T00:00:00+00:00/PT4H"]
}

variable "disk_default_retention_duration" {
  description = "Default retention duration for disk backups (e.g., P7D for 7 days)"
  type        = string
  default     = "P7D"
}

variable "create_blob_policy" {
  description = "Create a blob storage backup policy"
  type        = bool
  default     = false
}

variable "blob_retention_duration" {
  description = "Retention duration for blob backups (e.g., P30D for 30 days)"
  type        = string
  default     = "P30D"
}

variable "tags" {
  description = "Tags to apply to the backup vault"
  type        = map(string)
  default     = {}
}
