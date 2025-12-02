output "resource_group_name" {
  value       = azurerm_resource_group.this.name
  description = "Resource group created for the deployment."
}

output "location" {
  value       = azurerm_resource_group.this.location
  description = "Azure region where resources reside."
}

output "virtual_network_id" {
  value       = module.network.vnet_id
  description = "ID of the virtual network."
}

output "subnet_ids" {
  value       = module.network.subnet_ids
  description = "Map of subnet IDs keyed by subnet name."
}

output "nat_public_ip" {
  value       = module.network.nat_public_ip
  description = "Static public IP attached to the NAT gateway."
}

output "vm_private_ip" {
  value       = module.compute.private_ip
  description = "Private IP of the Ubuntu VM."
}

output "vm_admin_username" {
  value       = var.admin_username
  description = "Admin username for the Ubuntu VM."
}

output "vm_admin_password" {
  value       = var.admin_password
  description = "Admin password supplied via variables."
  sensitive   = true
}

output "app_gateway_public_ip" {
  value       = azurerm_public_ip.app_gateway.ip_address
  description = "Public IP address assigned to the Application Gateway."
}

output "log_analytics_workspace_id" {
  value       = azurerm_log_analytics_workspace.this.id
  description = "Resource ID of the Log Analytics workspace receiving VM data."
}

output "data_collection_rule_id" {
  value       = azurerm_monitor_data_collection_rule.vm.id
  description = "ID of the Azure Monitor data collection rule applied to the VM."
}

output "recovery_services_vault_id" {
  value       = azurerm_recovery_services_vault.vm.id
  description = "Resource ID of the Recovery Services vault protecting the VM backups."
}

output "storage_account_blob_endpoint" {
  value       = azurerm_storage_account.backups.primary_blob_endpoint
  description = "Blob service endpoint for application backups."
}

output "vm_managed_identity_principal_id" {
  value       = module.compute.identity_principal_id
  description = "Principal (object) ID of the VM's system-assigned managed identity."
}

output "vm_managed_identity_tenant_id" {
  value       = module.compute.identity_tenant_id
  description = "Tenant ID associated with the VM's managed identity."
}

output "container_registry_login_server" {
  value       = azurerm_container_registry.this.login_server
  description = "Container Registry login server for pushing/pulling images."
}
