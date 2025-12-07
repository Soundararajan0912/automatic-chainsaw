# Resource Group Activity Alerts (Terraform)

This module provisions an Azure Monitor Activity Log Alert that watches every event emitted inside a specific Resource Group (RG) and routes notifications to an Azure Monitor Action Group. Use it to be alerted when VMs, VNets, NICs, or any other resources inside the RG are created, updated, or deleted.

## What gets created
- `azurerm_monitor_action_group` scoped to your target RG (email + optional webhook receivers)
- `azurerm_monitor_activity_log_alert` scoped to the same RG, filtering on the `Administrative` category by default

## Prerequisites
- Existing Azure Resource Group you want to monitor
- Terraform >= 1.5
- Azure CLI (or service principal) authenticated with permissions to create monitor resources in the RG

## Inputs
See `variables.tf` for full details. Key variables:
- `resource_group_name`: RG to monitor
- `action_group_name` / `action_group_short_name`: names for the action group (short name max 12 chars)
- `action_email_receivers`: list of notification email addresses
- `webhook_receivers`: optional list of objects with `name`, `service_uri`, and optional `use_common_alert_schema`
- `event_category`: defaults to `Administrative`; change to `Security`, `Policy`, etc. if needed
- `event_levels`: list of Azure Monitor severity levels to match (`Critical`, `Error`, `Warning`, `Informational`, `Verbose`)

## Usage
1. Copy `terraform.tfvars.example` to `terraform.tfvars` and customize values.
2. Initialize and apply:
   ```bash
   cd terraform/rg-event-alerts
   terraform init
   terraform plan -var-file="terraform.tfvars"
   terraform apply -var-file="terraform.tfvars"
   ```
3. Trigger any change in the monitored RG (e.g., create a VM) to test that notifications arrive via the action group.

### Multiple email recipients
Set `action_email_receivers` to a list of strings; every address receives the alert:

```hcl
action_email_receivers = [
   "platform-alerts@example.com",
   "infra-oncall@example.com",
   "ops-manager@example.com"
]
```

### Event levels coverage
Azure Activity Log exposes exactly five `level` values. Include the ones you care about in `event_levels`:

| Level | Typical meaning |
|-------|-----------------|
| `Critical` | Platform-wide outage or severe issue from Azure | 
| `Error` | Failed operation (e.g., VM creation failed) |
| `Warning` | Operation succeeded with caveats, policy warnings |
| `Informational` | Successful resource operations (VM create/update/delete) |
| `Verbose` | Highly detailed diagnostic entries |

If you want emails for successful VM/VNet operations, make sure `Informational` (and optionally `Verbose`) are included.

## Outputs
- `action_group_id`
- `activity_log_alert_id`

Use these outputs for cross-referencing or to plug into downstream automation.
