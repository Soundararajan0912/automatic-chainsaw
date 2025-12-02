resource "azurerm_consumption_budget_resource_group" "this" {
  name              = var.name
  resource_group_id = var.resource_group_id
  amount            = var.amount
  time_grain        = var.time_grain

  time_period {
    start_date = var.time_period.start_date
    end_date   = var.time_period.end_date
  }

  dynamic "filter" {
    for_each = length(var.tag_filters) > 0 ? [1] : []
    content {
      dynamic "tag" {
        for_each = var.tag_filters
        content {
          name     = tag.value.name
          operator = tag.value.operator
          values   = tag.value.values
        }
      }
    }
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
