variable "lock_name" {
  description = "Name of the resource group lock to remove"
  type        = string
  default     = "lock-prevent-delete"
}

variable "resource_group_id" {
  description = "Resource ID of the target resource group"
  type        = string
}

variable "force_reapply" {
  description = "Toggle to force rerunning the unlock action"
  type        = bool
  default     = false
}
