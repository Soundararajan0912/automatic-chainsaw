terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "target" {
  name = var.resource_group_name
}

locals {
  email_receivers = { for idx, addr in var.action_email_receivers : format("email_%02d", idx) => addr }
  webhook_receivers = { for receiver in var.webhook_receivers : receiver.name => receiver }
}

resource "azurerm_monitor_action_group" "rg_events" {
  name                = var.action_group_name
  resource_group_name = data.azurerm_resource_group.target.name
  short_name          = var.action_group_short_name
  enabled             = true

  dynamic "email_receiver" {
    for_each = local.email_receivers
    content {
      name                    = email_receiver.key
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }

  dynamic "webhook_receiver" {
    for_each = local.webhook_receivers
    content {
      name                    = webhook_receiver.value.name
      service_uri             = webhook_receiver.value.service_uri
      use_common_alert_schema = coalesce(webhook_receiver.value.use_common_alert_schema, true)
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }

  tags = var.tags
}

resource "azurerm_monitor_activity_log_alert" "rg_events" {
  name                = var.alert_name
  resource_group_name = data.azurerm_resource_group.target.name
  scopes              = [data.azurerm_resource_group.target.id]
  description         = var.alert_description
  severity            = var.alert_severity
  enabled             = var.alert_enabled
  tags                = var.tags

  criteria {
    category = var.event_category
    levels   = var.event_levels
  }

  action {
    action_group_id = azurerm_monitor_action_group.rg_events.id
  }
}

output "action_group_id" {
  description = "ID of the monitor action group that receives notifications."
  value       = azurerm_monitor_action_group.rg_events.id
}

output "activity_log_alert_id" {
  description = "ID of the activity log alert covering the resource group."
  value       = azurerm_monitor_activity_log_alert.rg_events.id
}
