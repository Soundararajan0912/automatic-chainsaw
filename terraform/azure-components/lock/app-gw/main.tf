resource "azurerm_management_lock" "app_gateway" {
  name       = var.name
  scope      = var.app_gateway_id
  lock_level = var.lock_level
  notes      = var.notes
}
