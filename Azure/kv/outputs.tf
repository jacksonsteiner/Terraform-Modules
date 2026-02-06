output "key_vaults" {
  description = "Map of created Key Vaults with all attributes"
  value       = module.key_vaults
}

output "key_vault_ids" {
  description = "Map of Key Vault resource IDs"
  value       = { for k, v in module.key_vaults : k => v.resource_id }
}

output "key_vault_names" {
  description = "Map of Key Vault names"
  value       = { for k, v in module.key_vaults : k => v.name }
}

output "key_vault_uris" {
  description = "Map of Key Vault URIs for performing operations on keys and secrets"
  value       = { for k, v in module.key_vaults : k => v.uri }
}
