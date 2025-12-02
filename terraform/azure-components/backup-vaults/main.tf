resource "azurerm_data_protection_backup_vault" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  datastore_type      = var.datastore_type
  redundancy          = var.redundancy
  
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_data_protection_backup_policy_disk" "disk_policy" {
  count = var.create_disk_policy ? 1 : 0

  name                = "${var.name}-disk-policy"
  vault_id            = azurerm_data_protection_backup_vault.this.id

  backup_repeating_time_intervals = var.disk_backup_intervals

  default_retention_duration = var.disk_default_retention_duration
}

resource "azurerm_data_protection_backup_policy_blob_storage" "blob_policy" {
  count = var.create_blob_policy ? 1 : 0

  name               = "${var.name}-blob-policy"
  vault_id           = azurerm_data_protection_backup_vault.this.id
  retention_duration = var.blob_retention_duration
}
