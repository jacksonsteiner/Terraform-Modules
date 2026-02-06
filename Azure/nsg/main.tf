locals {
  suffix = join("-", compact([
    var.project_name, var.environment, var.location_short
  ]))

  names = {
    nsg = "nsg-${local.suffix}"
  }

  tags = {
    project     = var.project_name
    environment = var.environment
    location    = var.location
  }
}

module "network_security_groups" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.5"

  for_each = var.network_security_groups

  # Required
  name                = coalesce(try(each.value.name, null), "${local.names.nsg}-${each.key}")
  location            = coalesce(try(each.value.location, null), var.location)
  resource_group_name = each.value.resource_group_name

  # Optional - Telemetry
  enable_telemetry = coalesce(try(each.value.enable_telemetry, null), false)

  # Optional - Resource Lock
  lock = try(each.value.lock, null)

  # Optional - Role Assignments
  role_assignments = try(each.value.role_assignments, {})

  # Optional - Diagnostic Settings
  diagnostic_settings = try(each.value.diagnostic_settings, {})

  # Optional - Security Rules
  security_rules = {
    for k, v in try(each.value.security_rules, {}) : k => {
      # Required
      name      = coalesce(try(v.name, null), k)
      access    = v.access    # "Allow" or "Deny"
      direction = v.direction # "Inbound" or "Outbound"
      priority  = v.priority  # 100-4096
      protocol  = v.protocol  # "Tcp", "Udp", "Icmp", "Esp", "Ah", or "*"

      # Optional - Description
      description = try(v.description, null)

      # Optional - Source Configuration
      source_address_prefix                 = try(v.source_address_prefix, null)
      source_address_prefixes               = try(v.source_address_prefixes, null)
      source_application_security_group_ids = try(v.source_application_security_group_ids, null)
      source_port_range                     = try(v.source_port_range, null)
      source_port_ranges                    = try(v.source_port_ranges, null)

      # Optional - Destination Configuration
      destination_address_prefix                 = try(v.destination_address_prefix, null)
      destination_address_prefixes               = try(v.destination_address_prefixes, null)
      destination_application_security_group_ids = try(v.destination_application_security_group_ids, null)
      destination_port_range                     = try(v.destination_port_range, null)
      destination_port_ranges                    = try(v.destination_port_ranges, null)

      # Optional - Timeouts
      timeouts = try(v.timeouts, null)
    }
  }

  # Optional - Timeouts
  timeouts = try(each.value.timeouts, null)

  # Tags
  tags = merge(local.tags, try(each.value.tags, {}))
}
