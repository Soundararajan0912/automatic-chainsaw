variable "name" {
  description = "Name of the application gateway"
  type        = string
}

variable "location" {
  description = "Azure region where the application gateway will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "sku_name" {
  description = "SKU name (Standard_Small, Standard_Medium, Standard_Large, WAF_Medium, WAF_Large, Standard_v2, WAF_v2)"
  type        = string
  default     = "Standard_v2"
}

variable "sku_tier" {
  description = "SKU tier (Standard, Standard_v2, WAF, WAF_v2)"
  type        = string
  default     = "Standard_v2"
}

variable "capacity" {
  description = "Capacity (instance count) of the application gateway"
  type        = number
  default     = 2
}

variable "subnet_id" {
  description = "ID of the subnet where the application gateway will be deployed"
  type        = string
}

variable "backend_address_pool_name" {
  description = "Name of the backend address pool"
  type        = string
  default     = "backend-pool"
}

variable "tags" {
  description = "Tags to apply to the application gateway"
  type        = map(string)
  default     = {}
}
