variable "lock_name" {
  description = "Name of the VM lock to remove"
  type        = string
  default     = "lock-vm"
}

variable "virtual_machine_id" {
  description = "Resource ID of the virtual machine"
  type        = string
}

variable "force_reapply" {
  description = "Toggle to force rerunning the unlock action"
  type        = bool
  default     = false
}
