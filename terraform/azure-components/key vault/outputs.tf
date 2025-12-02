output "id" {
  description = "The ID of the key vault"
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "The name of the key vault"
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "The URI of the key vault"
  value       = azurerm_key_vault.this.vault_uri
}
