output "container_app_environment_id" {
  description = "Resource ID of the internal Container Apps environment."
  value       = azurerm_container_app_environment.internal.id
}

output "container_app_fqdns" {
  description = "Map of container app names to their internal FQDNs."
  value = { for name, app in azurerm_container_app.app :
    name => app.latest_revision_fqdn
  }
}

output "private_dns_zone_name" {
  description = "Name of the private DNS zone that resolves Container App FQDNs."
  value       = azurerm_private_dns_zone.container_apps.name
}

output "application_gateway_id" {
  description = "Resource ID of the Application Gateway."
  value       = azurerm_application_gateway.main.id
}

output "application_gateway_public_ip" {
  description = "Public IP address assigned to Application Gateway."
  value       = azurerm_public_ip.app_gateway.ip_address
}

output "application_gateway_public_fqdn" {
  description = "DNS label of the Application Gateway public IP (if configured)."
  value       = azurerm_public_ip.app_gateway.fqdn
}
