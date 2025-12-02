output "lock_name" {
  description = "The lock removed from the Key Vault"
  value       = module.unlock.lock_name
}

output "scope" {
  description = "Key Vault scope where the lock was removed"
  value       = module.unlock.scope
}
