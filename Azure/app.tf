# Azure AD Application Registration
# Note: No official AVM module exists for Azure AD applications.
# This module uses native azuread provider resources following AVM patterns.

resource "azuread_application" "foundation" {
  for_each = var.app_foundation

  # Required
  display_name = coalesce(try(each.value.display_name, null), "app-${local.suffix}-${each.key}")

  # Optional - Basic Configuration
  description                  = try(each.value.description, null)
  group_membership_claims      = try(each.value.group_membership_claims, null)
  identifier_uris              = try(each.value.identifier_uris, null)
  logo_image                   = try(each.value.logo_image, null)
  notes                        = try(each.value.notes, null)
  sign_in_audience             = try(each.value.sign_in_audience, "AzureADMyOrg") # Secure default - single tenant
  prevent_duplicate_names      = try(each.value.prevent_duplicate_names, true)
  service_management_reference = try(each.value.service_management_reference, null)

  # Security - Secure defaults
  fallback_public_client_enabled = try(each.value.fallback_public_client_enabled, false) # Secure default
  device_only_auth_enabled       = try(each.value.device_only_auth_enabled, false)
  oauth2_post_response_required  = try(each.value.oauth2_post_response_required, false)

  # Optional - Owners
  owners = try(each.value.owners, [data.azurerm_client_config.current.object_id])

  # Optional - Tags (Azure AD tags, not Azure resource tags)
  tags = try(each.value.app_tags, null)

  # Optional - Feature Tags
  dynamic "feature_tags" {
    for_each = try(each.value.feature_tags, null) != null ? [each.value.feature_tags] : []
    content {
      custom_single_sign_on = try(feature_tags.value.custom_single_sign_on, null)
      enterprise            = try(feature_tags.value.enterprise, null)
      gallery               = try(feature_tags.value.gallery, null)
      hide                  = try(feature_tags.value.hide, null)
    }
  }

  # Optional - API Configuration
  dynamic "api" {
    for_each = try(each.value.api, null) != null ? [each.value.api] : []
    content {
      known_client_applications      = try(api.value.known_client_applications, null)
      mapped_claims_enabled          = try(api.value.mapped_claims_enabled, null)
      requested_access_token_version = try(api.value.requested_access_token_version, 2) # v2 tokens recommended

      dynamic "oauth2_permission_scope" {
        for_each = try(api.value.oauth2_permission_scopes, {})
        content {
          id                         = oauth2_permission_scope.value.id
          value                      = oauth2_permission_scope.value.value
          admin_consent_display_name = try(oauth2_permission_scope.value.admin_consent_display_name, null)
          admin_consent_description  = try(oauth2_permission_scope.value.admin_consent_description, null)
          user_consent_display_name  = try(oauth2_permission_scope.value.user_consent_display_name, null)
          user_consent_description   = try(oauth2_permission_scope.value.user_consent_description, null)
          enabled                    = try(oauth2_permission_scope.value.enabled, true)
          type                       = try(oauth2_permission_scope.value.type, "User") # "Admin" or "User"
        }
      }
    }
  }

  # Optional - App Roles
  dynamic "app_role" {
    for_each = try(each.value.app_roles, {})
    content {
      id                   = app_role.value.id
      display_name         = app_role.value.display_name
      value                = try(app_role.value.value, null)
      description          = try(app_role.value.description, null)
      allowed_member_types = app_role.value.allowed_member_types # ["User"], ["Application"], or ["User", "Application"]
      enabled              = try(app_role.value.enabled, true)
    }
  }

  # Optional - Optional Claims
  dynamic "optional_claims" {
    for_each = try(each.value.optional_claims, null) != null ? [each.value.optional_claims] : []
    content {
      dynamic "access_token" {
        for_each = try(optional_claims.value.access_token, [])
        content {
          name                  = access_token.value.name
          additional_properties = try(access_token.value.additional_properties, null)
          essential             = try(access_token.value.essential, false)
          source                = try(access_token.value.source, null)
        }
      }
      dynamic "id_token" {
        for_each = try(optional_claims.value.id_token, [])
        content {
          name                  = id_token.value.name
          additional_properties = try(id_token.value.additional_properties, null)
          essential             = try(id_token.value.essential, false)
          source                = try(id_token.value.source, null)
        }
      }
      dynamic "saml2_token" {
        for_each = try(optional_claims.value.saml2_token, [])
        content {
          name                  = saml2_token.value.name
          additional_properties = try(saml2_token.value.additional_properties, null)
          essential             = try(saml2_token.value.essential, false)
          source                = try(saml2_token.value.source, null)
        }
      }
    }
  }

  # Optional - Public Client (Native/Mobile apps)
  dynamic "public_client" {
    for_each = try(each.value.public_client, null) != null ? [each.value.public_client] : []
    content {
      redirect_uris = try(public_client.value.redirect_uris, null)
    }
  }

  # Optional - Required Resource Access (API Permissions)
  dynamic "required_resource_access" {
    for_each = try(each.value.required_resource_access, {})
    content {
      resource_app_id = required_resource_access.value.resource_app_id

      dynamic "resource_access" {
        for_each = try(required_resource_access.value.resource_access, {})
        content {
          id   = resource_access.value.id
          type = resource_access.value.type # "Role" or "Scope"
        }
      }
    }
  }

  # Optional - Single Page Application
  dynamic "single_page_application" {
    for_each = try(each.value.single_page_application, null) != null ? [each.value.single_page_application] : []
    content {
      redirect_uris = try(single_page_application.value.redirect_uris, null)
    }
  }

  # Optional - Web Application
  dynamic "web" {
    for_each = try(each.value.web, null) != null ? [each.value.web] : []
    content {
      homepage_url  = try(web.value.homepage_url, null)
      logout_url    = try(web.value.logout_url, null)
      redirect_uris = try(web.value.redirect_uris, null)

      dynamic "implicit_grant" {
        for_each = try(web.value.implicit_grant, null) != null ? [web.value.implicit_grant] : []
        content {
          access_token_issuance_enabled = try(implicit_grant.value.access_token_issuance_enabled, false) # Secure default
          id_token_issuance_enabled     = try(implicit_grant.value.id_token_issuance_enabled, false)     # Secure default
        }
      }
    }
  }

  # Optional - Password Credentials (prefer managed identity or certificates)
  dynamic "password" {
    for_each = try(each.value.passwords, {})
    content {
      display_name = password.value.display_name
      start_date   = try(password.value.start_date, null)
      end_date     = try(password.value.end_date, null)
    }
  }

  lifecycle {
    ignore_changes = [
      # Passwords are often rotated outside of Terraform
    ]
  }
}

# Service Principal (Enterprise Application)
resource "azuread_service_principal" "foundation" {
  for_each = { for k, v in var.app_foundation : k => v if try(v.create_service_principal, true) }

  client_id                    = azuread_application.foundation[each.key].client_id
  description                  = try(each.value.service_principal_description, null)
  account_enabled              = try(each.value.service_principal_enabled, true)
  app_role_assignment_required = try(each.value.app_role_assignment_required, false)
  notes                        = try(each.value.service_principal_notes, null)
  login_url                    = try(each.value.login_url, null)
  notification_email_addresses = try(each.value.notification_email_addresses, null)
  owners                       = try(each.value.service_principal_owners, [data.azurerm_client_config.current.object_id])
  use_existing                 = try(each.value.use_existing_service_principal, false)

  # Optional - Tags
  tags = try(each.value.service_principal_tags, null)

  # Optional - Feature Tags
  dynamic "feature_tags" {
    for_each = try(each.value.service_principal_feature_tags, null) != null ? [each.value.service_principal_feature_tags] : []
    content {
      custom_single_sign_on = try(feature_tags.value.custom_single_sign_on, null)
      enterprise            = try(feature_tags.value.enterprise, null)
      gallery               = try(feature_tags.value.gallery, null)
      hide                  = try(feature_tags.value.hide, null)
    }
  }

  # Optional - SAML Single Sign-On
  dynamic "saml_single_sign_on" {
    for_each = try(each.value.saml_single_sign_on, null) != null ? [each.value.saml_single_sign_on] : []
    content {
      relay_state = try(saml_single_sign_on.value.relay_state, null)
    }
  }
}

# Optional - Federated Identity Credentials (for workload identity)
resource "azuread_application_federated_identity_credential" "foundation" {
  for_each = {
    for item in flatten([
      for app_key, app in var.app_foundation : [
        for fic_key, fic in try(app.federated_identity_credentials, {}) : {
          key          = "${app_key}-${fic_key}"
          app_key      = app_key
          fic_key      = fic_key
          display_name = fic.display_name
          description  = try(fic.description, null)
          audiences    = fic.audiences
          issuer       = fic.issuer
          subject      = fic.subject
        }
      ]
    ]) : item.key => item
  }

  application_id = azuread_application.foundation[each.value.app_key].id
  display_name   = each.value.display_name
  description    = each.value.description
  audiences      = each.value.audiences
  issuer         = each.value.issuer
  subject        = each.value.subject
}
