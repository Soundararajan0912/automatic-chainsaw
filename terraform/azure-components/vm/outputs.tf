output "id" {
  description = "The ID of the virtual machine"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].id : azurerm_windows_virtual_machine.this[0].id
}

output "name" {
  description = "The name of the virtual machine"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].name : azurerm_windows_virtual_machine.this[0].name
}

output "private_ip_address" {
  description = "The private IP address of the virtual machine"
  value       = azurerm_network_interface.this.private_ip_address
}

output "identity_principal_id" {
  description = "The principal ID of the system-assigned managed identity"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].identity[0].principal_id : azurerm_windows_virtual_machine.this[0].identity[0].principal_id
}
