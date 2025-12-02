output "lock_name" {
  description = "The lock removed from the Application Gateway"
  value       = module.unlock.lock_name
}

output "scope" {
  description = "Application Gateway scope where the lock was removed"
  value       = module.unlock.scope
}
