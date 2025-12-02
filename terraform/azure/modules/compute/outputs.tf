output "vm_id" {
  value       = azurerm_linux_virtual_machine.vm.id
  description = "ID of the deployed VM."
}

output "private_ip" {
  value       = azurerm_network_interface.vm.ip_configuration[0].private_ip_address
  description = "Private IP address of the VM."
}

output "nic_id" {
  value       = azurerm_network_interface.vm.id
  description = "ID of the VM network interface."
}

output "identity_principal_id" {
  value       = azurerm_linux_virtual_machine.vm.identity[0].principal_id
  description = "Principal ID of the VM's system-assigned managed identity."
}

output "identity_tenant_id" {
  value       = azurerm_linux_virtual_machine.vm.identity[0].tenant_id
  description = "Tenant ID associated with the VM's managed identity."
}
