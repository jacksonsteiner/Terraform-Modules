module "vnet_foundation" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1"

  for_each = var.vnet_foundation

  # Required
  location  = coalesce(try(each.value.location, null), var.location)
  parent_id = module.rg_foundation[each.value.rg_key].resource_id

  # Optional - Basic Configuration
  name                    = coalesce(try(each.value.name, null), "${local.names.vnet}-${each.key}")
  address_space           = try(each.value.address_space, null)
  bgp_community           = try(each.value.bgp_community, null)
  dns_servers             = try(each.value.dns_servers, null)
  enable_telemetry        = coalesce(try(each.value.enable_telemetry, null), false)
  enable_vm_protection    = try(each.value.enable_vm_protection, false)
  flow_timeout_in_minutes = try(each.value.flow_timeout_in_minutes, null)

  # Optional - DDoS Protection
  ddos_protection_plan = try(each.value.ddos_protection_plan, null)

  # Optional - Encryption
  encryption = try(each.value.encryption, null)

  # Optional - Extended Location (Edge Zones)
  extended_location = try(each.value.extended_location, null)

  # Optional - IPAM (IP Address Management) - only pass if explicitly provided
  # Note: This variable requires objects with 'id' attribute, so we don't pass it if not defined

  # Optional - Resource Lock
  lock = try(each.value.lock, null)

  # Optional - Role Assignments
  role_assignments = try(each.value.role_assignments, {})

  # Optional - Diagnostic Settings
  diagnostic_settings = try(each.value.diagnostic_settings, {})

  # Optional - VNet Peerings
  peerings = try(each.value.peerings, {})

  # Optional - Timeouts
  timeouts = coalesce(try(each.value.timeouts, null), {
    create = "30m"
    delete = "30m"
    read   = "5m"
    update = "30m"
  })

  # Optional - Retry Configuration
  retry = try(each.value.retry, {})

  # Subnets
  subnets = {
    for sk, s in try(each.value.subnets, {}) : sk => {
      # Required
      name = coalesce(try(s.name, null), sk)

      # Address Space (one of these required)
      address_prefix   = try(s.address_prefix, null)
      address_prefixes = try(s.address_prefixes, null)
      ipam_pools       = try(s.ipam_pools, null)

      # Optional - Network Associations
      nat_gateway            = try(s.nat_gateway, null)
      network_security_group = try(s.network_security_group, null)
      route_table            = try(s.route_table, null)

      # Optional - Private Endpoint/Link Policies
      private_endpoint_network_policies             = try(s.private_endpoint_network_policies, "Enabled")
      private_link_service_network_policies_enabled = try(s.private_link_service_network_policies_enabled, true)

      # Optional - Service Endpoints
      service_endpoints_with_location = try(s.service_endpoints_with_location, null)
      service_endpoint_policies       = try(s.service_endpoint_policies, null)

      # Optional - Delegations
      delegations = try(s.delegations, null)

      # Optional - Other Settings
      default_outbound_access_enabled = try(s.default_outbound_access_enabled, false)
      sharing_scope                   = try(s.sharing_scope, null)

      # Optional - Role Assignments (subnet-level)
      role_assignments = try(s.role_assignments, null)

      # Optional - Timeouts
      timeouts = try(s.timeouts, {})

      # Optional - Retry Configuration
      retry = try(s.retry, {})
    }
  }

  tags = merge(local.tags, try(each.value.tags, {}))
}