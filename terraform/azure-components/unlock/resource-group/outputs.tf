output "lock_name" {
  description = "The lock removed from the resource group"
  value       = module.unlock.lock_name
}

output "scope" {
  description = "Resource group scope where the lock was removed"
  value       = module.unlock.scope
}
