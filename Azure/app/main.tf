locals {
  suffix = join("-", compact([
    var.project_name, var.environment, var.location_short
  ]))

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

data "azurerm_client_config" "current" {}

resource "azuread_application" "this" {
  for_each = var.applications

  display_name                   = coalesce(try(each.value.display_name, null), "app-${local.suffix}-${each.key}")
  description                    = try(each.value.description, null)
  group_membership_claims        = try(each.value.group_membership_claims, null)
  identifier_uris                = try(each.value.identifier_uris, null)
  sign_in_audience              = try(each.value.sign_in_audience, "AzureADMyOrg")
  fallback_public_client_enabled = try(each.value.fallback_public_client_enabled, false)
  owners                         = try(each.value.owners, [data.azurerm_client_config.current.object_id])
  tags                           = try(each.value.app_tags, null)

  dynamic "api" {
    for_each = try(each.value.api, null) != null ? [each.value.api] : []
    content {
      known_client_applications      = try(api.value.known_client_applications, null)
      mapped_claims_enabled          = try(api.value.mapped_claims_enabled, null)
      requested_access_token_version = try(api.value.requested_access_token_version, 2)

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
          type                       = try(oauth2_permission_scope.value.type, "User")
        }
      }
    }
  }

  dynamic "web" {
    for_each = try(each.value.web, null) != null ? [each.value.web] : []
    content {
      homepage_url  = try(web.value.homepage_url, null)
      logout_url    = try(web.value.logout_url, null)
      redirect_uris = try(web.value.redirect_uris, null)

      dynamic "implicit_grant" {
        for_each = try(web.value.implicit_grant, null) != null ? [web.value.implicit_grant] : []
        content {
          access_token_issuance_enabled = try(implicit_grant.value.access_token_issuance_enabled, false)
          id_token_issuance_enabled     = try(implicit_grant.value.id_token_issuance_enabled, false)
        }
      }
    }
  }
}

resource "azuread_service_principal" "this" {
  for_each = { for k, v in var.applications : k => v if try(v.create_service_principal, true) }

  client_id                    = azuread_application.this[each.key].client_id
  description                  = try(each.value.service_principal_description, null)
  account_enabled              = try(each.value.service_principal_enabled, true)
  app_role_assignment_required = try(each.value.app_role_assignment_required, false)
  owners                       = try(each.value.service_principal_owners, [data.azurerm_client_config.current.object_id])
  tags                         = try(each.value.service_principal_tags, null)
}

resource "azuread_application_federated_identity_credential" "this" {
  for_each = {
    for item in flatten([
      for app_key, app in var.applications : [
        for fic_key, fic in try(app.federated_identity_credentials, {}) : {
          key          = "${app_key}-${fic_key}"
          app_key      = app_key
          display_name = fic.display_name
          description  = try(fic.description, null)
          audiences    = fic.audiences
          issuer       = fic.issuer
          subject      = fic.subject
        }
      ]
    ]) : item.key => item
  }

  application_id = azuread_application.this[each.value.app_key].id
  display_name   = each.value.display_name
  description    = each.value.description
  audiences      = each.value.audiences
  issuer         = each.value.issuer
  subject        = each.value.subject
}
