output "id" {
  description = "The ID of the VM lock"
  value       = azurerm_management_lock.virtual_machine.id
}

output "name" {
  description = "The name of the VM lock"
  value       = azurerm_management_lock.virtual_machine.name
}
