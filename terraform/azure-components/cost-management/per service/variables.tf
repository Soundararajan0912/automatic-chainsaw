variable "name" {
  description = "Name of the per-service budget"
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID in the format /subscriptions/<guid>"
  type        = string
}

variable "service_names" {
  description = "List of Azure service names to include (e.g., Microsoft.Compute/virtualMachines)"
  type        = list(string)
}

variable "amount" {
  description = "Budget amount"
  type        = number
}

variable "time_grain" {
  description = "Time grain for the budget (Monthly, Quarterly, Annually)"
  type        = string
  default     = "Monthly"
}

variable "time_period" {
  description = "Budget start and end dates"
  type = object({
    start_date = string
    end_date   = string
  })
}

variable "notifications" {
  description = "Notification configuration map"
  type = map(object({
    operator       = string
    threshold      = number
    threshold_type = string
    contact_emails = list(string)
    contact_roles  = optional(list(string), [])
    contact_groups = optional(list(string), [])
    enabled        = optional(bool, true)
  }))
  default = {
    Actual75 = {
      operator       = "GreaterThan"
      threshold      = 75
      threshold_type = "Actual"
      contact_emails = ["serviceowner@example.com"]
    }
  }
}
