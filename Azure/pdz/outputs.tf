output "private_dns_zones" {
  description = "Map of created private DNS zones with all attributes"
  value       = module.private_dns_zones
}

output "pdz_ids" {
  description = "Map of private DNS zone IDs"
  value       = { for k, v in module.private_dns_zones : k => v.resource_id }
}

output "pdz_names" {
  description = "Map of private DNS zone names"
  value       = { for k, v in module.private_dns_zones : k => v.name }
}
