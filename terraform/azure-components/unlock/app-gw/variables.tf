variable "lock_name" {
  description = "Name of the Application Gateway lock to remove"
  type        = string
  default     = "lock-appgw"
}

variable "app_gateway_id" {
  description = "Resource ID of the Application Gateway"
  type        = string
}

variable "force_reapply" {
  description = "Toggle to force rerunning the unlock action"
  type        = bool
  default     = false
}
