output "vnet_id" {
  value       = azurerm_virtual_network.this.id
  description = "ID of the created virtual network."
}

output "subnet_ids" {
  value       = { for name, subnet in azurerm_subnet.this : name => subnet.id }
  description = "Map of subnet IDs keyed by subnet name."
}

output "nat_gateway_id" {
  value       = azurerm_nat_gateway.this.id
  description = "ID of the NAT gateway."
}

output "nat_public_ip" {
  value       = azurerm_public_ip.nat.ip_address
  description = "Public IP assigned to the NAT gateway."
}
