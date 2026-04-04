variable "enterprise_applications" {
  type = map(object({
    # Required - client ID of the app registration this enterprise app is created from
    client_id = string

    # Optional - Basic Configuration
    display_name                   = optional(string)
    description                    = optional(string)
    account_enabled                = optional(bool, true)
    app_role_assignment_required   = optional(bool, false) # If true, users/groups must be explicitly assigned
    login_url                      = optional(string)
    notification_email_addresses   = optional(set(string), [])
    owners                         = optional(set(string))
    preferred_single_sign_on_mode  = optional(string) # "saml", "oidc", "password", "notSupported"
    tags                           = optional(set(string))

    # Optional - App Role Assignments (assign roles to users, groups, or service principals)
    app_role_assignments = optional(map(object({
      principal_object_id = string # Object ID of the user, group, or service principal
      app_role_id         = string # ID of the app role to assign; use "00000000-0000-0000-0000-000000000000" for default access
    })), {})

    # Optional - Delegated Permission Grants (admin consent for OAuth2 delegated scopes)
    delegated_permission_grants = optional(map(object({
      client_service_principal_object_id = string       # Object ID of the client service principal requesting access
      claim_values                       = list(string) # OAuth2 scope claim values e.g. ["openid", "profile", "email"]
    })), {})
  }))
  default     = {}
  description = "Map of enterprise applications (service principals) to create from existing app registrations"
}

variable "location_short" {
  type        = string
  description = "Short location identifier (e.g., 'eus', 'wus', 'cus')"
}

variable "environment" {
  type        = string
  description = "Environment identifier (e.g., 'dev', 'staging', 'prod')"
}

variable "project_name" {
  type        = string
  description = "Project name used for resource naming"
}
