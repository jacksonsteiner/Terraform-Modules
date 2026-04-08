variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "region_short" {
  description = "Short region identifier (e.g., use1, usw2, euw1)"
  type        = string
}

variable "oidc_roles" {
  description = "Map of IAM roles with OIDC trust policies for federated identity (e.g., GitHub Actions, EKS IRSA)"
  type = map(object({
    # Role Configuration
    role_name                    = optional(string)
    role_name_prefix             = optional(string)
    role_description             = optional(string, "")
    role_path                    = optional(string, "/")
    role_permissions_boundary_arn = optional(string, "")
    max_session_duration         = optional(number, 3600)

    # OIDC Provider
    provider_url  = optional(string, "")
    provider_urls = optional(list(string), [])
    aws_account_id = optional(string, "")

    # Trust Policy - OIDC Subjects & Audiences
    oidc_fully_qualified_subjects  = optional(set(string), [])
    oidc_subjects_with_wildcards   = optional(set(string), [])
    oidc_fully_qualified_audiences = optional(set(string), [])

    # Policy Attachments
    role_policy_arns          = optional(list(string), [])
    number_of_role_policy_arns = optional(number)

    # Security
    create_role         = optional(bool, true)
    allow_self_assume_role = optional(bool, false)
    force_detach_policies  = optional(bool, false)

    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}
