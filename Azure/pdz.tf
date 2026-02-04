module "pdz_foundation" {
  source  = "Azure/avm-res-network-privatednszone/azurerm"
  version = "0.4.4"

  for_each = var.pdz_foundation

  # Required
  domain_name = each.value.domain_name
  parent_id   = module.rg_foundation[each.value.rg_key].resource_id

  # Optional - Telemetry
  enable_telemetry = coalesce(try(each.value.enable_telemetry, null), false)

  # Optional - Role Assignments
  role_assignments = try(each.value.role_assignments, {})

  # Optional - SOA Record
  soa_record = try(each.value.soa_record, null)

  # Optional - DNS Records
  a_records     = coalesce(try(each.value.a_records, null), {})
  aaaa_records  = coalesce(try(each.value.aaaa_records, null), {})
  cname_records = coalesce(try(each.value.cname_records, null), {})
  mx_records    = coalesce(try(each.value.mx_records, null), {})
  ptr_records   = coalesce(try(each.value.ptr_records, null), {})
  srv_records   = coalesce(try(each.value.srv_records, null), {})
  txt_records   = coalesce(try(each.value.txt_records, null), {})

  # Virtual Network Links
  virtual_network_links = {
    for k, v in try(each.value.virtual_network_links, {}) : k => {
      vnetlinkname                           = coalesce(try(v.vnetlinkname, null), try(v.name, null), "${local.names.pdzvnl}-${k}")
      vnetid                                 = try(v.vnetid, null) != null ? v.vnetid : (try(v.vnet_key, null) != null ? module.vnet_foundation[v.vnet_key].resource_id : try(v.virtual_network_id, null))
      autoregistration                       = try(v.autoregistration, try(v.registration_enabled, false))
      private_dns_zone_supports_private_link = try(v.private_dns_zone_supports_private_link, false)
      resolution_policy                      = try(v.resolution_policy, "Default")
      tags                                   = try(v.tags, null)
    }
  }

  # Optional - Timeouts
  timeouts = coalesce(try(each.value.timeouts, null), {
    dns_zones = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
    virtual_network_links = {
      create = "30m"
      delete = "30m"
      read   = "5m"
      update = "30m"
    }
  })

  # Optional - Retry Configuration
  retry = try(each.value.retry, {})

  # Tags
  tags = merge(local.tags, try(each.value.tags, {}))
}
