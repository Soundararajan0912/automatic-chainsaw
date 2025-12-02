# Virtual Machine Unlock Module

Removes an existing management lock from a virtual machine via the shared `unlock` module.

## Usage

```hcl
module "vm_unlock" {
  source             = "../unlock/vm"
  virtual_machine_id = module.vm.id
  lock_name          = "lock-vm-prod"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| lock_name | Name of the VM lock to remove | string | "lock-vm" | no |
| virtual_machine_id | Resource ID of the virtual machine | string | n/a | yes |
| force_reapply | Toggle to force rerunning the unlock action | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| lock_name | The lock removed from the virtual machine |
| scope | Virtual machine scope where the lock was removed |
