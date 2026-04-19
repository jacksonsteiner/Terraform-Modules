locals {
  suffix = join("-", compact([var.project_name, var.environment, var.region_short]))

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 6.4.1"

  for_each = var.distributions

  aliases             = try(each.value.aliases, null)
  comment             = coalesce(try(each.value.comment, null), "${local.suffix}-${each.key}")
  enabled             = coalesce(try(each.value.enabled, null), true)
  is_ipv6_enabled     = coalesce(try(each.value.is_ipv6_enabled, null), true)
  http_version        = coalesce(try(each.value.http_version, null), "http2and3")
  default_root_object = try(each.value.default_root_object, "index.html")
  price_class         = coalesce(try(each.value.price_class, null), "PriceClass_100")
  retain_on_delete    = coalesce(try(each.value.retain_on_delete, null), false)
  wait_for_deployment = coalesce(try(each.value.wait_for_deployment, null), true)
  web_acl_id          = try(each.value.web_acl_id, null)

  # Origins
  origin = try(each.value.origin, {})

  # Origin Access Control (use OAC, not OAI)
  origin_access_control = try(each.value.origin_access_control, {
    s3 = {
      description      = "OAC for S3 origin"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  })

  # Cache Behaviors - HARDENED: redirect to HTTPS by default
  default_cache_behavior = merge(
    {
      viewer_protocol_policy = "redirect-to-https"
      compress               = true
      allowed_methods        = ["GET", "HEAD", "OPTIONS"]
      cached_methods         = ["GET", "HEAD"]
    },
    each.value.default_cache_behavior
  )

  ordered_cache_behavior = try(each.value.ordered_cache_behavior, [])

  # Viewer Certificate - HARDENED: TLS 1.2+ minimum
  viewer_certificate = merge(
    {
      minimum_protocol_version = "TLSv1.2_2021"
      ssl_support_method       = "sni-only"
    },
    try(each.value.viewer_certificate, {})
  )

  # Restrictions
  restrictions = try(each.value.restrictions, {
    geo_restriction = {
      restriction_type = "none"
    }
  })

  # Logging
  logging_config = try(each.value.logging_config, {})

  # Custom Error Responses
  custom_error_response = try(each.value.custom_error_response, null)

  # Response Headers Policies
  response_headers_policies = try(each.value.response_headers_policies, null)

  # CloudFront Functions
  cloudfront_functions = try(each.value.cloudfront_functions, null)

  # Monitoring
  create_monitoring_subscription      = coalesce(try(each.value.create_monitoring_subscription, null), false)
  realtime_metrics_subscription_status = coalesce(try(each.value.realtime_metrics_subscription_status, null), "Enabled")

  tags = merge(local.tags, try(each.value.tags, {}))
}
