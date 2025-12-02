output "id" {
  description = "The ID of the application gateway"
  value       = azurerm_application_gateway.this.id
}

output "name" {
  description = "The name of the application gateway"
  value       = azurerm_application_gateway.this.name
}

output "public_ip_address" {
  description = "The public IP address of the application gateway"
  value       = azurerm_public_ip.this.ip_address
}

output "backend_address_pool_id" {
  description = "The ID of the backend address pool"
  value       = tolist(azurerm_application_gateway.this.backend_address_pool)[0].id
}
