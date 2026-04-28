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

variable "distributions" {
  description = "Map of CloudFront distribution configurations"
  type = map(object({
    # Core
    aliases             = optional(list(string))
    comment             = optional(string)
    enabled             = optional(bool, true)
    is_ipv6_enabled     = optional(bool, true)
    http_version        = optional(string, "http2and3")
    default_root_object = optional(string, "index.html")
    price_class         = optional(string, "PriceClass_100")
    retain_on_delete    = optional(bool, false)
    wait_for_deployment = optional(bool, true)
    web_acl_id          = optional(string)
    tags                = optional(map(string))

    # Origins
    origin = optional(map(any), {})

    # Origin Access Control (OAC for S3 - hardened default)
    origin_access_control = optional(map(object({
      description      = optional(string, "OAC for S3 origin")
      origin_type      = optional(string, "s3")
      signing_behavior = optional(string, "always")
      signing_protocol = optional(string, "sigv4")
    })))

    # Cache Behaviors - HARDENED: redirect to HTTPS by default
    default_cache_behavior = object({
      target_origin_id         = string
      viewer_protocol_policy   = optional(string, "redirect-to-https")
      compress                 = optional(bool, true)
      allowed_methods          = optional(list(string), ["GET", "HEAD", "OPTIONS"])
      cached_methods           = optional(list(string), ["GET", "HEAD"])
      cache_policy_id          = optional(string)
      origin_request_policy_id = optional(string)
      use_forwarded_values     = optional(bool, false)
      query_string             = optional(bool, false)
      headers                  = optional(list(string))
      cookies_forward          = optional(string, "none")
      min_ttl                  = optional(number)
      default_ttl              = optional(number)
      max_ttl                  = optional(number)
      function_association     = optional(map(any))
      lambda_function_association = optional(map(any))
    })
    ordered_cache_behavior = optional(list(any), [])

    # Viewer Certificate - HARDENED: TLS 1.2+ minimum, SNI-only
    viewer_certificate = optional(object({
      minimum_protocol_version      = optional(string, "TLSv1.2_2021")
      ssl_support_method            = optional(string, "sni-only")
      cloudfront_default_certificate = optional(bool)
      acm_certificate_arn           = optional(string)
    }))

    # Restrictions
    restrictions = optional(object({
      geo_restriction = object({
        restriction_type = optional(string, "none")
        locations        = optional(list(string), [])
      })
    }))

    # Logging
    logging_config = optional(object({
      bucket          = string
      include_cookies = optional(bool, false)
      prefix          = optional(string)
    }))

    # Custom Error Responses
    custom_error_response = optional(list(any))

    # Response Headers Policies
    response_headers_policies = optional(map(any))

    # CloudFront Functions
    cloudfront_functions = optional(map(any))

    # Monitoring
    create_monitoring_subscription      = optional(bool, false)
    realtime_metrics_subscription_status = optional(string, "Enabled")
  }))
}
