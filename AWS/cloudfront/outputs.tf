output "distributions" {
  description = "Map of created CloudFront distributions with all attributes"
  value       = module.cloudfront
}

output "distribution_ids" {
  description = "Map of CloudFront distribution IDs"
  value       = { for k, v in module.cloudfront : k => v.cloudfront_distribution_id }
}

output "distribution_arns" {
  description = "Map of CloudFront distribution ARNs"
  value       = { for k, v in module.cloudfront : k => v.cloudfront_distribution_arn }
}

output "distribution_domain_names" {
  description = "Map of CloudFront distribution domain names"
  value       = { for k, v in module.cloudfront : k => v.cloudfront_distribution_domain_name }
}

output "distribution_hosted_zone_ids" {
  description = "Map of CloudFront distribution hosted zone IDs (for Route53 alias records)"
  value       = { for k, v in module.cloudfront : k => v.cloudfront_distribution_hosted_zone_id }
}

output "origin_access_controls" {
  description = "Map of origin access control IDs"
  value       = { for k, v in module.cloudfront : k => v.cloudfront_origin_access_controls }
}
