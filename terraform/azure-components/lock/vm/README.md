# Virtual Machine Lock Module

Creates an Azure management lock that targets a virtual machine to prevent accidental deletion or modification.

## Usage

```hcl
module "vm_lock" {
  source              = "../lock/vm"
  name                = "lock-vm-prod"
  virtual_machine_id  = module.vm.id
  lock_level          = "ReadOnly"
  notes               = "Prevents changes to production VM"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the management lock | string | n/a | yes |
| virtual_machine_id | Resource ID of the virtual machine | string | n/a | yes |
| lock_level | Lock level (CanNotDelete or ReadOnly) | string | n/a | yes |
| notes | Optional notes about the lock | string | null | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the VM lock |
| name | The name of the VM lock |
