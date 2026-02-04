module "kv_foundation" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.10.2"

  for_each = var.kv_foundation

  # Required
  name                = coalesce(try(each.value.name, null), "${local.names.kv}-${each.key}")
  location            = coalesce(try(each.value.location, null), var.location)
  resource_group_name = module.rg_foundation[each.value.rg_key].name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  # Optional - SKU
  sku_name = try(each.value.sku_name, "standard")

  # Optional - Telemetry
  enable_telemetry = coalesce(try(each.value.enable_telemetry, null), false)

  # Optional - Access Configuration
  enabled_for_deployment          = try(each.value.enabled_for_deployment, false)
  enabled_for_disk_encryption     = try(each.value.enabled_for_disk_encryption, false)
  enabled_for_template_deployment = try(each.value.enabled_for_template_deployment, false)

  # Optional - Network Configuration
  public_network_access_enabled = try(each.value.public_network_access_enabled, false)
  network_acls                  = try(each.value.network_acls, null)

  # Optional - Soft Delete & Purge Protection
  soft_delete_retention_days = try(each.value.soft_delete_retention_days, null)
  purge_protection_enabled   = try(each.value.purge_protection_enabled, true)

  # Optional - Resource Lock
  lock = try(each.value.lock, null)

  # Optional - Role Assignments
  role_assignments = {
    for k, v in try(each.value.role_assignments, {}) : k => {
      role_definition_id_or_name             = v.role_definition_id_or_name
      principal_id                           = coalesce(try(v.principal_id, null), data.azurerm_client_config.current.object_id)
      description                            = try(v.description, null)
      skip_service_principal_aad_check       = try(v.skip_service_principal_aad_check, false)
      condition                              = try(v.condition, null)
      condition_version                      = try(v.condition_version, null)
      delegated_managed_identity_resource_id = try(v.delegated_managed_identity_resource_id, null)
      principal_type                         = try(v.principal_type, null)
    }
  }

  # Optional - Legacy Access Policies
  legacy_access_policies_enabled = try(each.value.legacy_access_policies_enabled, false)
  legacy_access_policies         = try(each.value.legacy_access_policies, {})

  # Optional - Diagnostic Settings
  diagnostic_settings = try(each.value.diagnostic_settings, {})

  # Optional - Contacts
  contacts = coalesce(try(each.value.contacts, null), {})

  # Optional - Private Endpoints
  private_endpoints_manage_dns_zone_group = try(each.value.private_endpoints_manage_dns_zone_group, true)
  private_endpoints = {
    for k, v in try(each.value.private_endpoints, {}) : k => {
      name                                    = coalesce(try(v.name, null), "${local.names.pep}-${k}")
      subnet_resource_id                      = coalesce(try(v.subnet_resource_id, null), module.vnet_foundation[v.vnet_key].subnets[v.subnet_key].resource_id)
      private_dns_zone_group_name             = try(v.private_dns_zone_group_name, "default")
      private_dns_zone_resource_ids           = try(v.private_dns_zone_resource_ids, null) != null ? v.private_dns_zone_resource_ids : (try(v.pdz_key, null) != null ? [module.pdz_foundation[v.pdz_key].resource_id] : [])
      application_security_group_associations = try(v.application_security_group_associations, {})
      private_service_connection_name         = try(v.private_service_connection_name, null)
      network_interface_name                  = try(v.network_interface_name, null)
      location                                = coalesce(try(v.location, null), var.location)
      resource_group_name                     = try(v.resource_group_name, null)
      ip_configurations                       = try(v.ip_configurations, {})
      tags                                    = try(v.tags, null)
      lock                                    = try(v.lock, null)
      role_assignments                        = try(v.role_assignments, {})
    }
  }

  # Optional - Keys
  keys = try(each.value.keys, {})

  # Optional - Secrets
  secrets       = try(each.value.secrets, {})
  secrets_value = try(each.value.secrets_value, null)

  # Optional - RBAC Wait Configuration
  wait_for_rbac_before_key_operations     = try(each.value.wait_for_rbac_before_key_operations, {})
  wait_for_rbac_before_secret_operations  = try(each.value.wait_for_rbac_before_secret_operations, {})
  wait_for_rbac_before_contact_operations = try(each.value.wait_for_rbac_before_contact_operations, {})

  # Tags
  tags = merge(local.tags, try(each.value.tags, {}))
}