output "resource_groups" {
  description = "Map of created resource groups with all attributes"
  value       = module.resource_groups
}

output "resource_group_ids" {
  description = "Map of resource group IDs"
  value       = { for k, v in module.resource_groups : k => v.resource_id }
}

output "resource_group_names" {
  description = "Map of resource group names"
  value       = { for k, v in module.resource_groups : k => v.name }
}

output "resource_group_locations" {
  description = "Map of resource group locations"
  value       = { for k, v in module.resource_groups : k => v.location }
}
