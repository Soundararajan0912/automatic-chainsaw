output "id" {
  description = "The ID of the management lock"
  value       = azurerm_management_lock.this.id
}

output "name" {
  description = "The name of the management lock"
  value       = azurerm_management_lock.this.name
}
