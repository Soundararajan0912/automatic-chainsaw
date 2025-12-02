output "id" {
  description = "The ID of the backup vault"
  value       = azurerm_data_protection_backup_vault.this.id
}

output "name" {
  description = "The name of the backup vault"
  value       = azurerm_data_protection_backup_vault.this.name
}

output "principal_id" {
  description = "The principal ID of the system-assigned managed identity"
  value       = azurerm_data_protection_backup_vault.this.identity[0].principal_id
}

output "disk_policy_id" {
  description = "The ID of the disk backup policy"
  value       = var.create_disk_policy ? azurerm_data_protection_backup_policy_disk.disk_policy[0].id : null
}

output "blob_policy_id" {
  description = "The ID of the blob storage backup policy"
  value       = var.create_blob_policy ? azurerm_data_protection_backup_policy_blob_storage.blob_policy[0].id : null
}
