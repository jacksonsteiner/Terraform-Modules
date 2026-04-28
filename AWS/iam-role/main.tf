locals {
  suffix = join("-", compact([var.project_name, var.environment, var.region_short]))

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.4.0"

  for_each = var.oidc_roles

  create = coalesce(try(each.value.create, null), true)

  # Role Configuration
  name                 = try(each.value.name, null) != null ? each.value.name : "${local.suffix}-${each.key}"
  use_name_prefix      = coalesce(try(each.value.use_name_prefix, null), false)
  description          = try(each.value.description, null)
  path                 = try(each.value.path, "/")
  permissions_boundary = try(each.value.permissions_boundary, null)
  max_session_duration = try(each.value.max_session_duration, 3600)

  # OIDC Trust Policy
  enable_oidc            = coalesce(try(each.value.enable_oidc, null), true)
  enable_github_oidc     = coalesce(try(each.value.enable_github_oidc, null), false)
  github_provider        = try(each.value.github_provider, "token.actions.githubusercontent.com")
  oidc_account_id        = try(each.value.oidc_account_id, null)
  oidc_provider_urls     = try(each.value.oidc_provider_urls, [])
  oidc_subjects          = try(each.value.oidc_subjects, [])
  oidc_wildcard_subjects = try(each.value.oidc_wildcard_subjects, [])
  oidc_audiences         = try(each.value.oidc_audiences, [])

  # Managed Policy Attachments (name => ARN)
  policies = try(each.value.policies, {})

  tags = merge(local.tags, try(each.value.tags, {}))
}
