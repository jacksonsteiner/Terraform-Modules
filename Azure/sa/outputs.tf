output "storage_accounts" {
  description = "Map of created Storage Accounts with all attributes"
  value       = module.storage_accounts
}

output "storage_account_ids" {
  description = "Map of Storage Account resource IDs"
  value       = { for k, v in module.storage_accounts : k => v.resource_id }
}

output "storage_account_names" {
  description = "Map of Storage Account names"
  value       = { for k, v in module.storage_accounts : k => v.name }
}

output "storage_account_fqdns" {
  description = "Map of Storage Account service FQDNs (blob, file, queue, table, etc.)"
  value       = { for k, v in module.storage_accounts : k => v.fqdn }
}

output "storage_account_containers" {
  description = "Map of containers created per Storage Account"
  value       = { for k, v in module.storage_accounts : k => v.containers }
}

output "storage_account_private_endpoints" {
  description = "Map of private endpoints created per Storage Account"
  value       = { for k, v in module.storage_accounts : k => v.private_endpoints }
}
