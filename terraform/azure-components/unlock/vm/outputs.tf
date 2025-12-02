output "lock_name" {
  description = "The lock removed from the virtual machine"
  value       = module.unlock.lock_name
}

output "scope" {
  description = "Virtual machine scope where the lock was removed"
  value       = module.unlock.scope
}
