resource "azurerm_storage_container" "this" {
  name                              = var.name
  storage_account_name              = var.storage_account_name
  container_access_type             = var.container_access_type
  metadata                          = var.metadata
  default_encryption_scope          = var.default_encryption_scope
  prevent_encryption_scope_override = var.prevent_encryption_scope_override

  dynamic "immutability_policy" {
    for_each = var.immutability_policy != null ? [var.immutability_policy] : []
    content {
      state                                     = immutability_policy.value.state
      immutability_period_since_creation_in_days = immutability_policy.value.immutability_period_since_creation_in_days
      allow_protected_append_writes             = immutability_policy.value.allow_protected_append_writes
    }
  }
}
