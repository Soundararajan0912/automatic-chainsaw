variable "name" {
  description = "Name of the resource group budget"
  type        = string
}

variable "resource_group_id" {
  description = "ID of the target resource group"
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

variable "tag_filters" {
  description = "Optional tag-based filters"
  type = list(object({
    name     = string
    operator = string
    values   = list(string)
  }))
  default = []
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
    Actual80 = {
      operator       = "GreaterThan"
      threshold      = 80
      threshold_type = "Actual"
      contact_emails = ["owner@example.com"]
    }
  }
}
