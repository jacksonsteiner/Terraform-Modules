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

variable "apis" {
  type = map(object({
    # Core
    name          = optional(string)
    description   = optional(string)
    protocol_type = optional(string, "HTTP")
    body          = optional(string)
    api_version   = optional(string)
    tags          = optional(map(string))

    # Security - HARDENED
    disable_execute_api_endpoint = optional(bool, true)
    mutual_tls_authentication    = optional(map(string), {})

    # CORS
    cors_configuration = optional(object({
      allow_credentials = optional(bool)
      allow_headers     = optional(list(string))
      allow_methods     = optional(list(string))
      allow_origins     = optional(list(string))
      expose_headers    = optional(list(string))
      max_age           = optional(number)
    }))

    # Routes & Integrations
    routes      = optional(map(any), {})
    authorizers = optional(map(any), {})

    # Stage
    create_stage      = optional(bool, true)
    stage_name        = optional(string, "$default")
    stage_description = optional(string)
    stage_variables   = optional(map(string), {})
    stage_tags        = optional(map(string))

    # Stage - Access Logging HARDENED
    stage_access_log_settings = optional(object({
      create_log_group            = optional(bool)
      destination_arn             = optional(string)
      log_group_name              = optional(string)
      log_group_retention_in_days = optional(number)
      log_group_kms_key_id        = optional(string)
      log_group_class             = optional(string)
      log_group_skip_destroy      = optional(bool)
      format                      = optional(string)
    }))

    # Stage - Route Settings with throttling defaults
    stage_default_route_settings = optional(object({
      data_trace_enabled       = optional(bool)
      detailed_metrics_enabled = optional(bool)
      logging_level            = optional(string)
      throttling_burst_limit   = optional(number)
      throttling_rate_limit    = optional(number)
    }))

    # Domain
    create_domain_name          = optional(bool, false)
    domain_name                 = optional(string)
    domain_name_certificate_arn = optional(string)
    create_domain_records       = optional(bool, true)
    create_certificate          = optional(bool, false)
    subdomains                  = optional(list(string), [])

    # VPC Link
    vpc_links = optional(map(object({
      name               = optional(string)
      security_group_ids = optional(list(string), [])
      subnet_ids         = optional(list(string), [])
      tags               = optional(map(string), {})
    })), {})
  }))
  description = "Map of API Gateway v2 configurations to create. Keys are used as identifiers in resource naming."
  default     = {}
}
