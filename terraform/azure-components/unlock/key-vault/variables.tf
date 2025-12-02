variable "lock_name" {
  description = "Name of the Key Vault lock to remove"
  type        = string
  default     = "lock-keyvault"
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault"
  type        = string
}

variable "force_reapply" {
  description = "Toggle to force rerunning the unlock action"
  type        = bool
  default     = false
}
