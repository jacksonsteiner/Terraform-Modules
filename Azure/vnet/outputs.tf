output "virtual_networks" {
  description = "Map of created virtual networks with all attributes"
  value       = module.virtual_networks
}

output "vnet_ids" {
  description = "Map of virtual network IDs"
  value       = { for k, v in module.virtual_networks : k => v.resource_id }
}

output "vnet_names" {
  description = "Map of virtual network names"
  value       = { for k, v in module.virtual_networks : k => v.name }
}

output "vnet_locations" {
  description = "Map of virtual network locations"
  value       = { for k, v in module.virtual_networks : k => v.resource.location }
}

output "vnet_address_spaces" {
  description = "Map of virtual network address spaces"
  value       = { for k, v in module.virtual_networks : k => v.address_spaces }
}

output "subnets" {
  description = "Map of all subnets across all virtual networks"
  value       = { for k, v in module.virtual_networks : k => v.subnets }
}

output "vnet_peerings" {
  description = "Map of all VNet peerings across all virtual networks"
  value       = { for k, v in module.virtual_networks : k => v.peerings }
}
