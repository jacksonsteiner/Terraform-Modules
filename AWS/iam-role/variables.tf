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
    create               = optional(bool, true)
    name                 = optional(string)
    use_name_prefix      = optional(bool, false)
    description          = optional(string)
    path                 = optional(string, "/")
    permissions_boundary = optional(string)
    max_session_duration = optional(number, 3600)

    # OIDC Trust Policy
    enable_oidc        = optional(bool, true)
    enable_github_oidc = optional(bool, false)
    github_provider    = optional(string, "token.actions.githubusercontent.com")
    oidc_account_id    = optional(string)
    oidc_provider_urls = optional(list(string), [])

    # Trust scoping
    oidc_subjects          = optional(list(string), [])
    oidc_wildcard_subjects = optional(list(string), [])
    oidc_audiences         = optional(list(string), [])

    # Managed policy attachments: map of name => ARN
    policies = optional(map(string), {})

    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}
