variable "resource_group_name" {
  description = "Resource group for compute resources."
  type        = string
}

variable "location" {
  description = "Azure region for compute resources."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the VM NIC will reside."
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM."
  type        = string
}

variable "admin_password" {
  description = "Admin password for the VM."
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Size of the VM."
  type        = string
}

variable "vm_os_disk_size_gb" {
  description = "OS disk size for the VM."
  type        = number
}

variable "encryption_at_host_enabled" {
  description = "Whether to enable host-based encryption for the VM disks."
  type        = bool
  default     = true
}

variable "custom_image_id" {
  description = "Resource ID of the custom image to deploy."
  type        = string
}

variable "computer_name" {
  description = "Hostname/computer name for the VM."
  type        = string
}

variable "nginx_server_name" {
  description = "Server name used inside the nginx vhost created via cloud-init."
  type        = string
}

variable "tags" {
  description = "Tags for compute resources."
  type        = map(string)
  default     = {}
}
