output "tables" {
  description = "Map of created DynamoDB tables with all attributes"
  value       = module.dynamodb_table
}

output "table_arns" {
  description = "Map of DynamoDB table ARNs"
  value       = { for k, v in module.dynamodb_table : k => v.dynamodb_table_arn }
}

output "table_ids" {
  description = "Map of DynamoDB table IDs"
  value       = { for k, v in module.dynamodb_table : k => v.dynamodb_table_id }
}

output "table_stream_arns" {
  description = "Map of DynamoDB table stream ARNs"
  value       = { for k, v in module.dynamodb_table : k => try(v.dynamodb_table_stream_arn, null) }
}
