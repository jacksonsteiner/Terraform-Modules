output "bastions" {
  description = "Map of created Azure Bastion Hosts with all attributes"
  value       = module.bastions
}

output "bastion_ids" {
  description = "Map of Azure Bastion Host IDs"
  value       = { for k, v in module.bastions : k => v.resource_id }
}

output "bastion_names" {
  description = "Map of Azure Bastion Host names"
  value       = { for k, v in module.bastions : k => v.name }
}

output "bastion_dns_names" {
  description = "Map of Azure Bastion Host FQDNs"
  value       = { for k, v in module.bastions : k => v.dns_name }
}
