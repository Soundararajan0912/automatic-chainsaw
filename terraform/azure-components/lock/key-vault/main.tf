resource "azurerm_management_lock" "key_vault" {
  name       = var.name
  scope      = var.key_vault_id
  lock_level = var.lock_level
  notes      = var.notes
}
