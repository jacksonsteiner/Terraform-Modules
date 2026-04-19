locals {
  suffix = join("-", compact([var.project_name, var.environment, var.region_short]))

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 6.1.0"

  for_each = var.apis

  name          = coalesce(try(each.value.name, null), "${local.suffix}-${each.key}")
  description   = try(each.value.description, null)
  protocol_type = coalesce(try(each.value.protocol_type, null), "HTTP")
  body          = try(each.value.body, null)
  api_version   = try(each.value.api_version, null)

  # Security - Disable default execute-api endpoint (HARDENED)
  disable_execute_api_endpoint = coalesce(try(each.value.disable_execute_api_endpoint, null), true)

  # Security - Mutual TLS
  mutual_tls_authentication = try(each.value.mutual_tls_authentication, {})

  # CORS
  cors_configuration = try(each.value.cors_configuration, null)

  # Routes & Integrations
  routes      = try(each.value.routes, {})
  authorizers = try(each.value.authorizers, {})

  # Stage
  create_stage      = coalesce(try(each.value.create_stage, null), true)
  stage_name        = coalesce(try(each.value.stage_name, null), "$default")
  stage_description = try(each.value.stage_description, null)
  stage_variables   = try(each.value.stage_variables, {})
  stage_tags        = try(each.value.stage_tags, {})

  # Stage - Access Logging (HARDENED: encourage logging)
  stage_access_log_settings = try(each.value.stage_access_log_settings, {})

  # Stage - Route Settings with throttling
  stage_default_route_settings = try(each.value.stage_default_route_settings, {})

  # Domain
  create_domain_name          = coalesce(try(each.value.create_domain_name, null), false)
  domain_name                 = try(each.value.domain_name, "")
  domain_name_certificate_arn = try(each.value.domain_name_certificate_arn, null)
  create_domain_records       = coalesce(try(each.value.create_domain_records, null), true)
  create_certificate          = coalesce(try(each.value.create_certificate, null), false)
  subdomains                  = try(each.value.subdomains, [])

  # VPC Links
  vpc_links = try(each.value.vpc_links, {})

  tags = merge(local.tags, try(each.value.tags, {}))
}
