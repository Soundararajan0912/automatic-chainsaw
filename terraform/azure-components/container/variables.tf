variable "name" {
  description = "Name of the storage container"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the parent storage account"
  type        = string
}

variable "container_access_type" {
  description = "Access level of the container (blob, container, private)"
  type        = string
  default     = "private"
}

variable "metadata" {
  description = "Metadata key/value pairs"
  type        = map(string)
  default     = {}
}

variable "default_encryption_scope" {
  description = "Default encryption scope for the container"
  type        = string
  default     = null
}

variable "prevent_encryption_scope_override" {
  description = "Prevent objects from specifying a different encryption scope"
  type        = bool
  default     = false
}

variable "immutability_policy" {
  description = "Optional immutability policy configuration"
  type = object({
    state                                     = string
    immutability_period_since_creation_in_days = number
    allow_protected_append_writes             = bool
  })
  default = null
}
