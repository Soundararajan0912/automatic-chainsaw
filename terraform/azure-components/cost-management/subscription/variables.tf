variable "name" {
  description = "Name of the subscription budget"
  type        = string
}

variable "subscription_id" {
  description = "Subscription ID in the format /subscriptions/<guid>"
  type        = string
}

variable "amount" {
  description = "Budget amount in the currency of the subscription"
  type        = number
}

variable "time_grain" {
  description = "Time grain for the budget (Monthly, Quarterly, Annually)"
  type        = string
  default     = "Monthly"
}

variable "time_period" {
  description = "Time period for the budget"
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
    Forecast90 = {
      operator       = "GreaterThan"
      threshold      = 90
      threshold_type = "Forecasted"
      contact_emails = ["finance@example.com"]
      enabled        = true
    }
  }
}
