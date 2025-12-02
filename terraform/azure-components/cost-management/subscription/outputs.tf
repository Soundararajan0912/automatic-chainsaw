output "id" {
  description = "The ID of the subscription budget"
  value       = azurerm_consumption_budget_subscription.this.id
}

output "name" {
  description = "The name of the subscription budget"
  value       = azurerm_consumption_budget_subscription.this.name
}
