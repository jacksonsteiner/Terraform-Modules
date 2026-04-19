output "apis" {
  description = "Map of created API Gateways with all attributes"
  value       = module.api_gateway
}

output "api_ids" {
  description = "Map of API Gateway IDs"
  value       = { for k, v in module.api_gateway : k => v.api_id }
}

output "api_endpoints" {
  description = "Map of API Gateway endpoints"
  value       = { for k, v in module.api_gateway : k => v.api_endpoint }
}

output "api_execution_arns" {
  description = "Map of API Gateway execution ARNs"
  value       = { for k, v in module.api_gateway : k => v.api_execution_arn }
}

output "stage_ids" {
  description = "Map of API Gateway stage IDs"
  value       = { for k, v in module.api_gateway : k => try(v.stage_id, null) }
}

output "domain_names" {
  description = "Map of API Gateway custom domain names"
  value       = { for k, v in module.api_gateway : k => try(v.domain_name_id, null) }
}
