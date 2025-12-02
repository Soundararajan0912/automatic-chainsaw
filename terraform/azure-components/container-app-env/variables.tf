variable "name" {
  description = "Name of the container app environment"
  type        = string
}

variable "location" {
  description = "Azure region where the container app environment will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for monitoring"
  type        = string
}

variable "infrastructure_subnet_id" {
  description = "ID of the subnet for infrastructure (optional, for VNet integration)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the container app environment"
  type        = map(string)
  default     = {}
}
