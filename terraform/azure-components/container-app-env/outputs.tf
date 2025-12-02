output "id" {
  description = "The ID of the container app environment"
  value       = azurerm_container_app_environment.this.id
}

output "name" {
  description = "The name of the container app environment"
  value       = azurerm_container_app_environment.this.name
}

output "default_domain" {
  description = "The default domain of the container app environment"
  value       = azurerm_container_app_environment.this.default_domain
}

output "static_ip_address" {
  description = "The static IP address of the container app environment"
  value       = azurerm_container_app_environment.this.static_ip_address
}
