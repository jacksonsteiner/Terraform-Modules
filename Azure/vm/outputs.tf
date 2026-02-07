output "virtual_machines" {
  description = "Map of created Virtual Machines with all attributes"
  value       = module.virtual_machines
  sensitive   = true
}

output "vm_ids" {
  description = "Map of Virtual Machine resource IDs"
  value       = { for k, v in module.virtual_machines : k => v.resource_id }
}

output "vm_names" {
  description = "Map of Virtual Machine names"
  value       = { for k, v in module.virtual_machines : k => v.name }
}

output "vm_principal_ids" {
  description = "Map of Virtual Machine system-assigned managed identity principal IDs"
  value       = { for k, v in module.virtual_machines : k => v.system_assigned_mi_principal_id }
}
