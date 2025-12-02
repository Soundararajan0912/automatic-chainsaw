variable "name" {
  description = "Name of the subnet"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
}

variable "service_endpoints" {
  description = "List of service endpoints to enable on the subnet"
  type        = list(string)
  default     = []
}

variable "delegations" {
  description = "Subnet delegations configuration"
  type = list(object({
    name         = string
    service_name = string
    actions      = list(string)
  }))
  default = []
}
