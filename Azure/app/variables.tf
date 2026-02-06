variable "applications" {
  type = map(object({
    # Optional - Basic Configuration
    display_name                   = optional(string)
    description                    = optional(string)
    group_membership_claims        = optional(set(string))
    identifier_uris                = optional(set(string))
    sign_in_audience               = optional(string, "AzureADMyOrg")
    fallback_public_client_enabled = optional(bool, false)
    owners                         = optional(set(string))
    app_tags                       = optional(set(string))

    # Optional - API Configuration
    api = optional(object({
      known_client_applications      = optional(set(string))
      mapped_claims_enabled          = optional(bool)
      requested_access_token_version = optional(number, 2)
      oauth2_permission_scopes       = optional(map(object({
        id                         = string
        value                      = string
        admin_consent_display_name = optional(string)
        admin_consent_description  = optional(string)
        user_consent_display_name  = optional(string)
        user_consent_description   = optional(string)
        enabled                    = optional(bool, true)
        type                       = optional(string, "User")
      })))
    }))

    # Optional - Web Configuration
    web = optional(object({
      homepage_url  = optional(string)
      logout_url    = optional(string)
      redirect_uris = optional(set(string))
      implicit_grant = optional(object({
        access_token_issuance_enabled = optional(bool, false)
        id_token_issuance_enabled     = optional(bool, false)
      }))
    }))

    # Optional - Service Principal
    create_service_principal         = optional(bool, true)
    service_principal_description    = optional(string)
    service_principal_enabled        = optional(bool, true)
    app_role_assignment_required     = optional(bool, false)
    service_principal_owners         = optional(set(string))
    service_principal_tags           = optional(set(string))

    # Optional - Federated Identity Credentials
    federated_identity_credentials = optional(map(object({
      display_name = string
      description  = optional(string)
      audiences    = list(string)
      issuer       = string
      subject      = string
    })))
  }))
  default     = {}
  description = "Map of Azure AD Applications to create with service principals and federated identity credentials"
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
