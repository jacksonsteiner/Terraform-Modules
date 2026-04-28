output "oidc_roles" {
  description = "Map of created IAM OIDC roles with all attributes"
  value       = module.iam_role
}

output "oidc_role_arns" {
  description = "Map of IAM role ARNs"
  value       = { for k, v in module.iam_role : k => v.arn }
}

output "oidc_role_names" {
  description = "Map of IAM role names"
  value       = { for k, v in module.iam_role : k => v.name }
}

output "oidc_role_unique_ids" {
  description = "Map of IAM role unique IDs"
  value       = { for k, v in module.iam_role : k => v.unique_id }
}
