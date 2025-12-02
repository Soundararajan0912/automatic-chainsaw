variable "name" {
  description = "Name of the management lock"
  type        = string
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault"
  type        = string
}

variable "lock_level" {
  description = "Lock level (CanNotDelete or ReadOnly)"
  type        = string
  validation {
    condition     = contains(["CanNotDelete", "ReadOnly"], var.lock_level)
    error_message = "lock_level must be either 'CanNotDelete' or 'ReadOnly'"
  }
}

variable "notes" {
  description = "Optional notes about the lock"
  type        = string
  default     = null
}
