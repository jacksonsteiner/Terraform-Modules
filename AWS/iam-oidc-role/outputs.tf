output "oidc_roles" {
  description = "Map of created IAM OIDC roles with all attributes"
  value       = module.iam_assumable_role_with_oidc
}

output "oidc_role_arns" {
  description = "Map of IAM role ARNs"
  value       = { for k, v in module.iam_assumable_role_with_oidc : k => v.iam_role_arn }
}

output "oidc_role_names" {
  description = "Map of IAM role names"
  value       = { for k, v in module.iam_assumable_role_with_oidc : k => v.iam_role_name }
}

output "oidc_role_unique_ids" {
  description = "Map of IAM role unique IDs"
  value       = { for k, v in module.iam_assumable_role_with_oidc : k => v.iam_role_unique_id }
}
