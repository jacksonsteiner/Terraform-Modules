output "applications" {
  description = "Map of created Azure AD applications"
  value       = azuread_application.this
}

output "service_principals" {
  description = "Map of created service principals"
  value       = azuread_service_principal.this
}

output "application_ids" {
  description = "Map of application IDs"
  value       = { for k, v in azuread_application.this : k => v.id }
}

output "client_ids" {
  description = "Map of client IDs (application IDs)"
  value       = { for k, v in azuread_application.this : k => v.client_id }
}
