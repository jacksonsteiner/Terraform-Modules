locals {
  suffix = join("-", compact([
    var.project_name, var.environment, var.location_short
  ]))

  # Storage account names must be 3-24 chars, lowercase alphanumeric only
  sa_base = lower(replace(join("", compact([
    var.project_name, var.environment, var.location_short
  ])), "/[^a-z0-9]/", ""))

  names = {
    pep = "pep-${local.suffix}"
  }

  tags = {
    project     = var.project_name
    environment = var.environment
    location    = var.location
  }
}

module "storage_accounts" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.6"

  for_each = var.storage_accounts

  # Required
  name                = coalesce(try(each.value.name, null), substr("st${local.sa_base}${replace(each.key, "/[^a-z0-9]/", "")}", 0, 24))
  location            = coalesce(try(each.value.location, null), var.location)
  resource_group_name = each.value.resource_group_name

  # Optional - Telemetry
  enable_telemetry = coalesce(try(each.value.enable_telemetry, null), false)

  # Optional - Account configuration
  account_kind                     = try(each.value.account_kind, "StorageV2")
  account_tier                     = try(each.value.account_tier, "Standard")
  account_replication_type         = try(each.value.account_replication_type, "LRS")
  access_tier                      = try(each.value.access_tier, "Hot")
  cross_tenant_replication_enabled = try(each.value.cross_tenant_replication_enabled, false)
  edge_zone                        = try(each.value.edge_zone, null)
  allowed_copy_scope               = try(each.value.allowed_copy_scope, null)

  # Optional - Security
  https_traffic_only_enabled        = try(each.value.https_traffic_only_enabled, true)
  min_tls_version                   = try(each.value.min_tls_version, "TLS1_2")
  infrastructure_encryption_enabled = try(each.value.infrastructure_encryption_enabled, true)
  allow_nested_items_to_be_public   = try(each.value.allow_nested_items_to_be_public, false)
  shared_access_key_enabled         = try(each.value.shared_access_key_enabled, false)
  default_to_oauth_authentication   = try(each.value.default_to_oauth_authentication, true)
  public_network_access_enabled     = try(each.value.public_network_access_enabled, false)

  # Optional - Features
  nfsv3_enabled      = try(each.value.nfsv3_enabled, false)
  sftp_enabled       = try(each.value.sftp_enabled, false)
  local_user_enabled = try(each.value.local_user_enabled, false)
  local_user         = try(each.value.local_user, {})

  # Optional - Customer Managed Key
  customer_managed_key = try(each.value.customer_managed_key, null)

  # Optional - Identity
  managed_identities = try(each.value.managed_identities, {})

  # Optional - Network Rules (deny by default)
  network_rules = try(each.value.network_rules, {
    bypass                     = ["AzureServices"]
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  })

  # Optional - Custom Domain / Routing / SAS Policy
  custom_domain = try(each.value.custom_domain, null)
  routing       = try(each.value.routing, null)
  sas_policy    = try(each.value.sas_policy, null)

  # Optional - Azure Files Authentication
  azure_files_authentication = try(each.value.azure_files_authentication, null)
  large_file_share_enabled   = try(each.value.large_file_share_enabled, null)

  # Optional - Encryption
  queue_encryption_key_type = try(each.value.queue_encryption_key_type, null)
  table_encryption_key_type = try(each.value.table_encryption_key_type, null)

  # Optional - Blob / Share / Queue / Static website properties
  blob_properties  = try(each.value.blob_properties, null)
  share_properties = try(each.value.share_properties, null)
  queue_properties = try(each.value.queue_properties, {})
  static_website   = try(each.value.static_website, null)

  # Optional - Resources
  containers                         = try(each.value.containers, {})
  queues                             = try(each.value.queues, {})
  shares                             = try(each.value.shares, {})
  tables                             = try(each.value.tables, {})
  storage_data_lake_gen2_filesystems = try(each.value.storage_data_lake_gen2_filesystems, {})
  is_hns_enabled                     = try(each.value.is_hns_enabled, false)
  immutability_policy                = try(each.value.immutability_policy, null)

  # Optional - Management Policy
  storage_management_policy_rule = try(each.value.storage_management_policy_rule, {})

  # Optional - Resource Lock
  lock = try(each.value.lock, null)

  # Optional - Role Assignments
  role_assignments = try(each.value.role_assignments, {})

  # Optional - Diagnostic Settings (account + sub-services)
  diagnostic_settings_storage_account = try(each.value.diagnostic_settings, {})
  diagnostic_settings_blob            = try(each.value.diagnostic_settings_blob, {})
  diagnostic_settings_file            = try(each.value.diagnostic_settings_file, {})
  diagnostic_settings_queue           = try(each.value.diagnostic_settings_queue, {})
  diagnostic_settings_table           = try(each.value.diagnostic_settings_table, {})

  # Optional - Private Endpoints
  private_endpoints_manage_dns_zone_group = try(each.value.private_endpoints_manage_dns_zone_group, true)
  private_endpoints = {
    for k, v in try(each.value.private_endpoints, {}) : k => {
      name                                    = coalesce(try(v.name, null), "${local.names.pep}-${each.key}-${k}")
      subnet_resource_id                      = v.subnet_resource_id
      subresource_name                        = v.subresource_name
      private_dns_zone_group_name             = try(v.private_dns_zone_group_name, "default")
      private_dns_zone_resource_ids           = try(v.private_dns_zone_resource_ids, [])
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

  # Tags
  tags = merge(local.tags, try(each.value.tags, {}))
}
