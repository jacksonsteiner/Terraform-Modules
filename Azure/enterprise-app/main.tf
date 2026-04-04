resource "azuread_service_principal" "this" {
  for_each = var.enterprise_applications

  client_id                    = each.value.client_id
  description                  = try(each.value.description, null)
  account_enabled              = try(each.value.account_enabled, true)
  app_role_assignment_required = try(each.value.app_role_assignment_required, false)
  login_url                    = try(each.value.login_url, null)
  notification_email_addresses = try(each.value.notification_email_addresses, [])
  owners                       = try(each.value.owners, null)
  preferred_single_sign_on_mode = try(each.value.preferred_single_sign_on_mode, null)
  tags                         = try(each.value.tags, null)
}

resource "azuread_app_role_assignment" "this" {
  for_each = {
    for item in flatten([
      for app_key, app in var.enterprise_applications : [
        for assignment_key, assignment in try(app.app_role_assignments, {}) : {
          key                  = "${app_key}-${assignment_key}"
          app_key              = app_key
          principal_object_id  = assignment.principal_object_id
          app_role_id          = assignment.app_role_id
        }
      ]
    ]) : item.key => item
  }

  principal_object_id = each.value.principal_object_id
  resource_object_id  = azuread_service_principal.this[each.value.app_key].object_id
  app_role_id         = each.value.app_role_id
}

resource "azuread_service_principal_delegated_permission_grant" "this" {
  for_each = {
    for item in flatten([
      for app_key, app in var.enterprise_applications : [
        for grant_key, grant in try(app.delegated_permission_grants, {}) : {
          key                                = "${app_key}-${grant_key}"
          app_key                            = app_key
          client_service_principal_object_id = grant.client_service_principal_object_id
          claim_values                       = grant.claim_values
        }
      ]
    ]) : item.key => item
  }

  service_principal_object_id        = azuread_service_principal.this[each.value.app_key].object_id
  client_service_principal_object_id = each.value.client_service_principal_object_id
  claim_values                       = each.value.claim_values
}
