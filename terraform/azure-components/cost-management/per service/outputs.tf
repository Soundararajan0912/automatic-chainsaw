output "id" {
  description = "The ID of the per-service budget"
  value       = azurerm_consumption_budget_subscription.per_service.id
}

output "name" {
  description = "The name of the per-service budget"
  value       = azurerm_consumption_budget_subscription.per_service.name
}
