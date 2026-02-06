variable "virtual_networks" {
  type = map(object({
    # Required
    parent_id = string # Resource Group ID where VNet will be created

    # Optional - Basic Configuration
    name                    = optional(string)
    location                = optional(string)
    address_space           = optional(set(string))
    bgp_community           = optional(string)
    enable_telemetry        = optional(bool, false)
    enable_vm_protection    = optional(bool, false)
    flow_timeout_in_minutes = optional(number)

    # Optional - DNS Servers
    dns_servers = optional(object({
      dns_servers = list(string)
    }))

    # Optional - DDoS Protection Plan
    ddos_protection_plan = optional(object({
      id     = string
      enable = bool
    }))

    # Optional - Encryption
    encryption = optional(object({
      enabled     = bool
      enforcement = string # "AllowUnencrypted" or "DropUnencrypted"
    }))

    # Optional - Extended Location (Edge Zones)
    extended_location = optional(object({
      name = string
      type = optional(string, "EdgeZone")
    }))

    # Optional - IPAM (IP Address Management)
    # Either address_space or ipam_pools must be specified, but not both.
    # Only one IPv4 and one IPv6 pool can be specified.
    ipam_pools = optional(list(object({
      id            = string # Resource ID of the IPAM pool
      prefix_length = number # CIDR prefix length (2-29 for IPv4, 48-64 for IPv6)
    })))

    # Optional - Resource Lock
    lock = optional(object({
      kind = string # "CanNotDelete" or "ReadOnly"
      name = optional(string)
    }))

    # Optional - Role Assignments (VNet-level)
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string)
      condition_version                      = optional(string)
      delegated_managed_identity_resource_id = optional(string)
      principal_type                         = optional(string)
    })))

    # Optional - Diagnostic Settings
    diagnostic_settings = optional(map(object({
      name                                     = optional(string)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string)
      storage_account_resource_id              = optional(string)
      event_hub_authorization_rule_resource_id = optional(string)
      event_hub_name                           = optional(string)
      marketplace_partner_resource_id          = optional(string)
    })))

    # Optional - VNet Peerings
    peerings = optional(map(object({
      name                               = string
      remote_virtual_network_resource_id = string
      allow_forwarded_traffic            = optional(bool, false)
      allow_gateway_transit              = optional(bool, false)
      allow_virtual_network_access       = optional(bool, true)
      do_not_verify_remote_gateways      = optional(bool, false)
      enable_only_ipv6_peering           = optional(bool, false)
      peer_complete_vnets                = optional(bool, true)
      use_remote_gateways                = optional(bool, false)
      local_peered_address_spaces = optional(list(object({
        address_prefix = string
      })))
      remote_peered_address_spaces = optional(list(object({
        address_prefix = string
      })))
      local_peered_subnets = optional(list(object({
        subnet_name = string
      })))
      remote_peered_subnets = optional(list(object({
        subnet_name = string
      })))
      create_reverse_peering                = optional(bool, false)
      reverse_name                          = optional(string)
      reverse_allow_forwarded_traffic       = optional(bool, false)
      reverse_allow_gateway_transit         = optional(bool, false)
      reverse_allow_virtual_network_access  = optional(bool, true)
      reverse_do_not_verify_remote_gateways = optional(bool, false)
      reverse_enable_only_ipv6_peering      = optional(bool, false)
      reverse_peer_complete_vnets           = optional(bool, true)
      reverse_use_remote_gateways           = optional(bool, false)
      reverse_local_peered_address_spaces = optional(list(object({
        address_prefix = string
      })))
      reverse_remote_peered_address_spaces = optional(list(object({
        address_prefix = string
      })))
      reverse_local_peered_subnets = optional(list(object({
        subnet_name = string
      })))
      reverse_remote_peered_subnets = optional(list(object({
        subnet_name = string
      })))
      sync_remote_address_space_enabled  = optional(bool, false)
      sync_remote_address_space_triggers = optional(any)
      timeouts = optional(object({
        create = optional(string, "30m")
        read   = optional(string, "5m")
        update = optional(string, "30m")
        delete = optional(string, "30m")
      }))
      retry = optional(object({
        error_message_regex  = optional(list(string), ["ReferencedResourceNotProvisioned"])
        interval_seconds     = optional(number, 10)
        max_interval_seconds = optional(number, 180)
      }))
    })))

    # Optional - Timeouts
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))

    # Optional - Retry Configuration
    retry = optional(object({
      error_message_regex  = optional(list(string))
      interval_seconds     = optional(number)
      max_interval_seconds = optional(number)
    }))

    # Subnets
    subnets = optional(map(object({
      # Required
      name = optional(string)

      # Address Space (one of these required unless using IPAM)
      address_prefix   = optional(string)
      address_prefixes = optional(list(string))

      # Optional - IPAM
      ipam_pools = optional(list(object({
        pool_id         = string
        prefix_length   = optional(number)
        allocation_type = optional(string, "Static")
      })))

      # Optional - Network Associations
      nat_gateway = optional(object({
        id = string
      }))
      network_security_group = optional(object({
        id = string
      }))
      route_table = optional(object({
        id = string
      }))

      # Optional - Private Endpoint/Link Policies
      private_endpoint_network_policies             = optional(string, "Enabled")
      private_link_service_network_policies_enabled = optional(bool, true)

      # Optional - Service Endpoints
      service_endpoints_with_location = optional(list(object({
        service   = string
        locations = optional(list(string), ["*"])
      })))
      service_endpoint_policies = optional(map(object({
        id = string
      })))

      # Optional - Delegations
      delegations = optional(list(object({
        name = string
        service_delegation = object({
          name = string
        })
      })))

      # Optional - Other Settings
      default_outbound_access_enabled = optional(bool, false)
      sharing_scope                   = optional(string)

      # Optional - Role Assignments (subnet-level)
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        description                            = optional(string)
        skip_service_principal_aad_check       = optional(bool, false)
        condition                              = optional(string)
        condition_version                      = optional(string)
        delegated_managed_identity_resource_id = optional(string)
        principal_type                         = optional(string)
      })))

      # Optional - Timeouts
      timeouts = optional(object({
        create = optional(string, "30m")
        read   = optional(string, "5m")
        update = optional(string, "30m")
        delete = optional(string, "30m")
      }))

      # Optional - Retry Configuration
      retry = optional(object({
        error_message_regex  = optional(list(string), ["ReferencedResourceNotProvisioned"])
        interval_seconds     = optional(number, 10)
        max_interval_seconds = optional(number, 180)
      }))
    })), {})

    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of Virtual Networks to create with all AVM module options exposed"
}

variable "location_short" {
  type        = string
  description = "Short location identifier (e.g., 'eus', 'wus', 'cus')"
}

variable "environment" {
  type        = string
  description = "Environment identifier (e.g., 'dev', 'staging', 'prod')"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created (e.g., 'eastus', 'westus')"
}

variable "project_name" {
  type        = string
  description = "Project name used for resource naming"
}
