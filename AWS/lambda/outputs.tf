output "functions" {
  description = "Map of created Lambda functions with all attributes"
  value       = module.lambda
}

output "function_arns" {
  description = "Map of Lambda function ARNs"
  value       = { for k, v in module.lambda : k => v.lambda_function_arn }
}

output "function_names" {
  description = "Map of Lambda function names"
  value       = { for k, v in module.lambda : k => v.lambda_function_name }
}

output "function_invoke_arns" {
  description = "Map of Lambda function invoke ARNs"
  value       = { for k, v in module.lambda : k => v.lambda_function_invoke_arn }
}

output "function_role_arns" {
  description = "Map of Lambda IAM role ARNs"
  value       = { for k, v in module.lambda : k => v.lambda_role_arn }
}

output "function_role_names" {
  description = "Map of Lambda IAM role names"
  value       = { for k, v in module.lambda : k => v.lambda_role_name }
}

output "function_urls" {
  description = "Map of Lambda function URLs (if created)"
  value       = { for k, v in module.lambda : k => try(v.lambda_function_url, null) }
}
