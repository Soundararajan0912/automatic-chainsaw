variable "resource_group_name" {
  type        = string
  description = "Existing Azure Resource Group to monitor for activity events."
}

variable "alert_name" {
  type        = string
  description = "Name for the Azure Monitor activity log alert rule."
}

variable "alert_description" {
  type        = string
  description = "Friendly description that explains the purpose of the alert."
  default     = "Resource group activity alert"
}

variable "alert_severity" {
  type        = string
  description = "Alert severity (Sev0..Sev4)."
  default     = "Sev3"
  validation {
    condition     = contains(["Sev0", "Sev1", "Sev2", "Sev3", "Sev4"], var.alert_severity)
    error_message = "alert_severity must be one of Sev0, Sev1, Sev2, Sev3, Sev4."
  }
}

variable "alert_enabled" {
  type        = bool
  description = "Controls whether the alert is enabled."
  default     = true
}

variable "event_category" {
  type        = string
  description = "Activity log category to monitor (Administrative, Security, ServiceHealth, Policy, Recommendation)."
  default     = "Administrative"
}

variable "event_levels" {
  type        = list(string)
  description = "Activity log levels that should trigger the alert."
  default     = ["Critical", "Error", "Warning", "Informational", "Verbose"]
}

variable "action_group_name" {
  type        = string
  description = "Action group resource name (must be unique within the resource group)."
}

variable "action_group_short_name" {
  type        = string
  description = "Action group short name (2-12 characters)."
}

variable "action_email_receivers" {
  type        = list(string)
  description = "Email addresses to notify via the action group."
  default     = []
}

variable "webhook_receivers" {
  type = list(object({
    name                    = string
    service_uri             = string
    use_common_alert_schema = optional(bool, true)
  }))
  description = "Optional webhook endpoints that will receive Azure Monitor payloads."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Optional tags applied to created resources."
  default     = {}
}
