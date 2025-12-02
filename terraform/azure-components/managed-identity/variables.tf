variable "name" {
  description = "Name of the managed identity"
  type        = string
}

variable "location" {
  description = "Azure region where the managed identity will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the managed identity"
  type        = map(string)
  default     = {}
}
