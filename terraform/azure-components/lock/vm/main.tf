resource "azurerm_management_lock" "virtual_machine" {
  name       = var.name
  scope      = var.virtual_machine_id
  lock_level = var.lock_level
  notes      = var.notes
}
