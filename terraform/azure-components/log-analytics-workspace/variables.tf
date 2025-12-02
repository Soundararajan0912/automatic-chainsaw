variable "name" {
  description = "Name of the Log Analytics workspace"
  type        = string
}

variable "location" {
  description = "Azure region where the Log Analytics workspace will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "sku" {
  description = "SKU of the Log Analytics workspace (PerGB2018, Free, Standard, Premium, PerNode, Standalone)"
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Retention period in days (30-730)"
  type        = number
  default     = 30
}

variable "daily_quota_gb" {
  description = "Daily ingestion limit in GB (-1 for no limit)"
  type        = number
  default     = -1
}

variable "tags" {
  description = "Tags to apply to the Log Analytics workspace"
  type        = map(string)
  default     = {}
}
