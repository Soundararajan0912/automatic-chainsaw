output "id" {
  description = "The ID of the Application Gateway lock"
  value       = azurerm_management_lock.app_gateway.id
}

output "name" {
  description = "The name of the Application Gateway lock"
  value       = azurerm_management_lock.app_gateway.name
}
