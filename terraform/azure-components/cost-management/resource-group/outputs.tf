output "id" {
  description = "The ID of the resource group budget"
  value       = azurerm_consumption_budget_resource_group.this.id
}

output "name" {
  description = "The name of the resource group budget"
  value       = azurerm_consumption_budget_resource_group.this.name
}
