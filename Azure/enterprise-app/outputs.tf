output "service_principals" {
  description = "Map of created enterprise application service principals"
  value       = azuread_service_principal.this
}

output "service_principal_object_ids" {
  description = "Map of service principal object IDs"
  value       = { for k, v in azuread_service_principal.this : k => v.object_id }
}

output "service_principal_client_ids" {
  description = "Map of service principal client IDs"
  value       = { for k, v in azuread_service_principal.this : k => v.client_id }
}

output "app_role_assignments" {
  description = "Map of app role assignments"
  value       = azuread_app_role_assignment.this
}

output "delegated_permission_grants" {
  description = "Map of delegated permission grants"
  value       = azuread_service_principal_delegated_permission_grant.this
}
