output "network_security_groups" {
  description = "Map of created network security groups with all attributes"
  value       = module.network_security_groups
}

output "nsg_ids" {
  description = "Map of network security group IDs"
  value       = { for k, v in module.network_security_groups : k => v.resource_id }
}

output "nsg_names" {
  description = "Map of network security group names"
  value       = { for k, v in module.network_security_groups : k => v.name }
}
