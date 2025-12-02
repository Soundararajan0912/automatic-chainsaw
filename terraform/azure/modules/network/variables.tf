variable "resource_group_name" {
  description = "Resource group where network objects will be created."
  type        = string
}

variable "location" {
  description = "Azure region for the network."
  type        = string
}

variable "vnet_address_space" {
  description = "CIDR for the virtual network."
  type        = string
}

variable "subnet_map" {
  description = "Map of subnet names to CIDR prefixes."
  type        = map(string)
}

variable "nat_subnet_names" {
  description = "Subnets that require NAT gateway association."
  type        = list(string)
}

variable "app_gateway_subnet_name" {
  description = "Subnet name that will host the Application Gateway."
  type        = string
}

variable "tags" {
  description = "Tags to apply to network resources."
  type        = map(string)
  default     = {}
}
