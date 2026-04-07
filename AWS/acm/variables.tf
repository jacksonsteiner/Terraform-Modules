variable "project_name" {
  type        = string
  description = "Project name used for resource naming and tagging"
}

variable "environment" {
  type        = string
  description = "Environment identifier (e.g., 'dev', 'staging', 'prod')"
}

variable "region_short" {
  type        = string
  description = "Short region code used in naming (e.g., 'use1', 'usw2')"
}

variable "certificates" {
  description = "Map of ACM certificates to create"
  type = map(object({
    domain_name                                  = string
    subject_alternative_names                     = optional(list(string), [])
    validation_method                             = optional(string, "DNS")
    zone_id                                       = optional(string, "")
    zones                                         = optional(map(string), {})
    create_route53_records                        = optional(bool, true)
    validate_certificate                          = optional(bool, true)
    wait_for_validation                           = optional(bool, true)
    validation_timeout                            = optional(string)
    certificate_transparency_logging_preference   = optional(bool, true)
    key_algorithm                                 = optional(string)
    validation_allow_overwrite_records            = optional(bool, true)
    validation_option                             = optional(any, {})
    validation_record_fqdns                       = optional(list(string), [])
    dns_ttl                                       = optional(number, 60)
    tags                                          = optional(map(string))
  }))
  default = {}
}
