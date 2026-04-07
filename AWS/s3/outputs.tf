output "s3_buckets" {
  description = "Map of created S3 buckets with all attributes"
  value       = module.s3_bucket
}

output "s3_bucket_ids" {
  description = "Map of S3 bucket IDs"
  value       = { for k, v in module.s3_bucket : k => v.s3_bucket_id }
}

output "s3_bucket_arns" {
  description = "Map of S3 bucket ARNs"
  value       = { for k, v in module.s3_bucket : k => v.s3_bucket_arn }
}

output "s3_bucket_domain_names" {
  description = "Map of S3 bucket domain names"
  value       = { for k, v in module.s3_bucket : k => v.s3_bucket_bucket_domain_name }
}

output "s3_bucket_regional_domain_names" {
  description = "Map of S3 bucket regional domain names"
  value       = { for k, v in module.s3_bucket : k => v.s3_bucket_bucket_regional_domain_name }
}
