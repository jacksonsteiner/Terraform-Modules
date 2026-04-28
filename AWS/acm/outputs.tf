output "certificates" {
  description = "Map of created ACM certificates with all attributes"
  value       = module.acm
}

output "certificate_arns" {
  description = "Map of ACM certificate ARNs"
  value       = { for k, v in module.acm : k => v.acm_certificate_arn }
}

output "certificate_domain_validation_options" {
  description = "Map of domain validation options for certificates"
  value       = { for k, v in module.acm : k => v.acm_certificate_domain_validation_options }
}

output "certificate_statuses" {
  description = "Map of certificate statuses"
  value       = { for k, v in module.acm : k => v.acm_certificate_status }
}

output "validation_route53_record_fqdns" {
  description = "Map of Route53 validation record FQDNs"
  value       = { for k, v in module.acm : k => v.validation_route53_record_fqdns }
}
