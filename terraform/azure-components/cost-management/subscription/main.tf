resource "azurerm_consumption_budget_subscription" "this" {
  name            = var.name
  subscription_id = var.subscription_id
  amount          = var.amount
  time_grain      = var.time_grain

  time_period {
    start_date = var.time_period.start_date
    end_date   = var.time_period.end_date
  }

  dynamic "notification" {
    for_each = var.notifications
    content {
      enabled        = lookup(notification.value, "enabled", true)
      operator       = notification.value.operator
      threshold      = notification.value.threshold
      threshold_type = notification.value.threshold_type
      contact_emails = notification.value.contact_emails
      contact_roles  = lookup(notification.value, "contact_roles", [])
      contact_groups = lookup(notification.value, "contact_groups", [])
    }
  }
}
