locals {
  suffix = join("-", compact([var.project_name, var.environment, var.region_short]))

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 6.3.0"

  for_each = var.certificates

  domain_name = each.value.domain_name

  subject_alternative_names = try(each.value.subject_alternative_names, [])

  # Validation - DNS preferred for automation
  validation_method                  = coalesce(try(each.value.validation_method, null), "DNS")
  zone_id                            = try(each.value.zone_id, "")
  zones                              = try(each.value.zones, {})
  create_route53_records             = coalesce(try(each.value.create_route53_records, null), true)
  validate_certificate               = coalesce(try(each.value.validate_certificate, null), true)
  wait_for_validation                = coalesce(try(each.value.wait_for_validation, null), true)
  validation_timeout                 = try(each.value.validation_timeout, null)
  validation_allow_overwrite_records = coalesce(try(each.value.validation_allow_overwrite_records, null), true)
  validation_option                  = try(each.value.validation_option, {})
  validation_record_fqdns            = try(each.value.validation_record_fqdns, [])
  dns_ttl                            = coalesce(try(each.value.dns_ttl, null), 60)

  # Security - Certificate Transparency (enabled by default)
  certificate_transparency_logging_preference = coalesce(try(each.value.certificate_transparency_logging_preference, null), true)

  # Key Algorithm
  key_algorithm = try(each.value.key_algorithm, null)

  tags = merge(local.tags, try(each.value.tags, {}))
}
