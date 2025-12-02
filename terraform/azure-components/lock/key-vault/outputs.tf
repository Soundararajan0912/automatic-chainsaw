output "id" {
  description = "The ID of the Key Vault lock"
  value       = azurerm_management_lock.key_vault.id
}

output "name" {
  description = "The name of the Key Vault lock"
  value       = azurerm_management_lock.key_vault.name
}
