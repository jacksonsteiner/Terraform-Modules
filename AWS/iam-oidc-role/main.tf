locals {
  suffix = join("-", compact([var.project_name, var.environment, var.region_short]))

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

module "iam_assumable_role_with_oidc" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  for_each = var.oidc_roles

  create_role = coalesce(try(each.value.create_role, null), true)

  # Role Configuration
  role_name                     = try(each.value.role_name, null) != null ? each.value.role_name : "${local.suffix}-${each.key}"
  role_name_prefix              = try(each.value.role_name_prefix, null)
  role_description              = try(each.value.role_description, "")
  role_path                     = try(each.value.role_path, "/")
  role_permissions_boundary_arn = try(each.value.role_permissions_boundary_arn, "")
  max_session_duration          = try(each.value.max_session_duration, 3600)

  # OIDC Provider
  provider_url   = try(each.value.provider_url, "")
  provider_urls  = try(each.value.provider_urls, [])
  aws_account_id = try(each.value.aws_account_id, "")

  # Trust Policy - OIDC Subjects & Audiences
  oidc_fully_qualified_subjects  = try(each.value.oidc_fully_qualified_subjects, [])
  oidc_subjects_with_wildcards   = try(each.value.oidc_subjects_with_wildcards, [])
  oidc_fully_qualified_audiences = try(each.value.oidc_fully_qualified_audiences, [])

  # Policy Attachments
  role_policy_arns           = try(each.value.role_policy_arns, [])
  number_of_role_policy_arns = try(each.value.number_of_role_policy_arns, null)

  # Security
  allow_self_assume_role = coalesce(try(each.value.allow_self_assume_role, null), false)
  force_detach_policies  = coalesce(try(each.value.force_detach_policies, null), false)

  tags = merge(local.tags, try(each.value.tags, {}))
}
