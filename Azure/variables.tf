locals {

  suffix = join("-", compact([
    var.project_name, var.environment, var.location_short
  ]))

  names = {
    aks     = "aks-${local.suffix}"
    bastion = "bastion-${local.suffix}"
    kv      = "kv-${local.suffix}"
    nsg     = "nsg-${local.suffix}"
    pdz     = "pdz-${local.suffix}"
    pdzvnl  = "pdzvnl-${local.suffix}"
    pep     = "pep-${local.suffix}"
    pip     = "pip-${local.suffix}"
    rg      = "rg-${local.suffix}"
    snet    = "snet-${var.module_name}-${local.suffix}"
    vm      = "vm-${local.suffix}"
    vnet    = "vnet-${local.suffix}"
  }

  tags = {
    project     = var.project_name
    environment = var.environment
    location    = var.location
  }
}

variable "rg_foundation" {
  type = map(object({
    # Optional - Basic Configuration
    name             = optional(string)
    location         = optional(string)
    enable_telemetry = optional(bool, false)

    # Optional - Resource Lock
    lock = optional(object({
      kind = string # "CanNotDelete" or "ReadOnly"
      name = optional(string)
    }))

    # Optional - Role Assignments
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

    # Tags
    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of Resource Groups to create with all AVM module options exposed"
}

variable "vnet_foundation" {
  type = map(object({
    # Required
    rg_key = string

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
    ipam_pools = optional(list(object({
      pool_id         = string
      prefix_length   = optional(number)
      allocation_type = optional(string, "Static")
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

variable "bastion_foundation" {
  type = map(object({
    # Required - Resource References
    rg_key     = string
    vnet_key   = string
    subnet_key = string # must be "AzureBastionSubnet"

    # Optional - Basic Configuration
    name             = optional(string)
    location         = optional(string)
    enable_telemetry = optional(bool, false)

    # Optional - SKU Configuration
    sku = optional(string, "Basic") # "Basic", "Standard", "Developer", or "Premium"

    # Optional - Feature Flags (SKU-dependent)
    copy_paste_enabled        = optional(bool, true)  # Standard/Premium only
    file_copy_enabled         = optional(bool, false) # Standard/Premium only
    ip_connect_enabled        = optional(bool, false) # Standard/Premium only
    kerberos_enabled          = optional(bool, false) # Non-Developer SKUs only
    shareable_link_enabled    = optional(bool, false) # Standard/Premium only
    tunneling_enabled         = optional(bool, false) # Standard/Premium only
    session_recording_enabled = optional(bool, false) # Premium only
    private_only_enabled      = optional(bool, false) # Premium only

    # Optional - Scale and Availability
    scale_units = optional(number, 2)
    zones       = optional(set(string)) # Default: ["1", "2", "3"], empty for Developer SKU

    # Optional - Virtual Network (Developer SKU only)
    virtual_network_id = optional(string)

    # Optional - Resource Lock
    lock = optional(object({
      kind = string # "CanNotDelete" or "ReadOnly"
      name = optional(string)
    }))

    # Optional - Role Assignments
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

    # IP Configuration
    ip_configuration = optional(object({
      name                             = optional(string)
      create_public_ip                 = optional(bool, true)
      public_ip_address_id             = optional(string) # Use existing public IP instead of creating
      public_ip_address_name           = optional(string)
      public_ip_tags                   = optional(map(string))
      public_ip_merge_with_module_tags = optional(bool, true)
    }))

    # Tags
    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of Azure Bastion Hosts to create with all AVM module options exposed"
}

variable "kv_foundation" {
  type = map(object({
    # Required - Resource Reference
    rg_key = string

    # Optional - Basic Configuration
    name             = optional(string)
    location         = optional(string)
    enable_telemetry = optional(bool, false)

    # Optional - SKU
    sku_name = optional(string, "standard") # "standard" or "premium" (use premium only for HSM-backed keys)

    # Optional - Access Configuration
    enabled_for_deployment          = optional(bool, false)
    enabled_for_disk_encryption     = optional(bool, false)
    enabled_for_template_deployment = optional(bool, false)

    # Optional - Network Configuration
    public_network_access_enabled = optional(bool, false)
    network_acls = optional(object({
      bypass                     = optional(string, "None") # "None" or "AzureServices"
      default_action             = optional(string, "Deny") # "Allow" or "Deny"
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }))

    # Optional - Soft Delete & Purge Protection
    soft_delete_retention_days = optional(number) # 7-90 days
    purge_protection_enabled   = optional(bool, true)

    # Optional - Resource Lock
    lock = optional(object({
      kind = string # "CanNotDelete" or "ReadOnly"
      name = optional(string)
    }))

    # Optional - Role Assignments
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = optional(string) # Defaults to current client
      description                            = optional(string)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string)
      condition_version                      = optional(string)
      delegated_managed_identity_resource_id = optional(string)
      principal_type                         = optional(string)
    })))

    # Optional - Legacy Access Policies (disables RBAC)
    legacy_access_policies_enabled = optional(bool, false)
    legacy_access_policies = optional(map(object({
      object_id               = string
      application_id          = optional(string)
      certificate_permissions = optional(set(string), [])
      key_permissions         = optional(set(string), [])
      secret_permissions      = optional(set(string), [])
      storage_permissions     = optional(set(string), [])
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

    # Optional - Contacts
    contacts = optional(map(object({
      email = string
      name  = optional(string)
      phone = optional(string)
    })))

    # Optional - Private Endpoints
    private_endpoints_manage_dns_zone_group = optional(bool, true)
    private_endpoints = optional(map(object({
      name                                    = optional(string)
      subnet_resource_id                      = optional(string) # Use this OR subnet_key/vnet_key
      subnet_key                              = optional(string) # Reference to vnet_foundation subnet
      vnet_key                                = optional(string) # Reference to vnet_foundation
      pdz_key                                 = optional(string) # Reference to pdz_foundation
      private_dns_zone_group_name             = optional(string, "default")
      private_dns_zone_resource_ids           = optional(set(string))
      application_security_group_associations = optional(map(string), {})
      private_service_connection_name         = optional(string)
      network_interface_name                  = optional(string)
      location                                = optional(string)
      resource_group_name                     = optional(string)
      ip_configurations = optional(map(object({
        name               = string
        private_ip_address = optional(string)
      })), {})
      tags = optional(map(string))
      lock = optional(object({
        kind = string
        name = optional(string)
      }))
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
    })))

    # Optional - Keys
    keys = optional(map(object({
      name            = string
      key_type        = string # "RSA", "RSA-HSM", "EC", "EC-HSM"
      key_opts        = optional(list(string), ["sign", "verify"])
      key_size        = optional(number)
      curve           = optional(string) # "P-256", "P-384", "P-521", "secp256k1"
      not_before_date = optional(string)
      expiration_date = optional(string)
      tags            = optional(map(any))
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
      rotation_policy = optional(object({
        automatic = optional(object({
          time_after_creation = optional(string)
          time_before_expiry  = optional(string)
        }))
        expire_after         = optional(string)
        notify_before_expiry = optional(string)
      }))
    })))

    # Optional - Secrets
    secrets = optional(map(object({
      name            = string
      content_type    = optional(string)
      tags            = optional(map(any))
      not_before_date = optional(string)
      expiration_date = optional(string)
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
    })))
    secrets_value = optional(map(string)) # Sensitive - actual secret values

    # Optional - RBAC Wait Configuration
    wait_for_rbac_before_key_operations = optional(object({
      create  = optional(string, "30s")
      destroy = optional(string, "0s")
    }))
    wait_for_rbac_before_secret_operations = optional(object({
      create  = optional(string, "30s")
      destroy = optional(string, "0s")
    }))
    wait_for_rbac_before_contact_operations = optional(object({
      create  = optional(string, "30s")
      destroy = optional(string, "0s")
    }))

    # Tags
    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of Key Vaults to create with all AVM module options exposed"
}

variable "pep_foundation" {
  type = map(object({
    kv_key           = string
    pdz_keys         = list(string)
    subnet_key       = string
    vnet_key         = string
    name             = optional(string)
    enable_telemetry = optional(bool, false)
    tags             = optional(map(string))
  }))
  default = {}
}

variable "nsg_foundation" {
  type = map(object({
    # Required - Resource Reference
    rg_key = string

    # Optional - Basic Configuration
    name             = optional(string)
    location         = optional(string)
    enable_telemetry = optional(bool, false)

    # Optional - Resource Lock
    lock = optional(object({
      kind = string # "CanNotDelete" or "ReadOnly"
      name = optional(string)
    }))

    # Optional - Role Assignments
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

    # Security Rules
    security_rules = optional(map(object({
      # Required
      name      = optional(string) # Defaults to map key if not provided
      access    = string           # "Allow" or "Deny"
      direction = string           # "Inbound" or "Outbound"
      priority  = number           # 100-4096, lower = higher priority
      protocol  = string           # "Tcp", "Udp", "Icmp", "Esp", "Ah", or "*"

      # Optional - Description
      description = optional(string) # Max 140 characters

      # Optional - Source Configuration (use one of prefix, prefixes, or ASG)
      source_address_prefix                 = optional(string)      # CIDR, IP, or service tag
      source_address_prefixes               = optional(set(string)) # Multiple sources
      source_application_security_group_ids = optional(set(string)) # ASG references
      source_port_range                     = optional(string)      # Port or range (0-65535 or "*")
      source_port_ranges                    = optional(set(string)) # Multiple ports

      # Optional - Destination Configuration (use one of prefix, prefixes, or ASG)
      destination_address_prefix                 = optional(string)      # CIDR, IP, or service tag
      destination_address_prefixes               = optional(set(string)) # Multiple destinations
      destination_application_security_group_ids = optional(set(string)) # ASG references
      destination_port_range                     = optional(string)      # Port or range (0-65535 or "*")
      destination_port_ranges                    = optional(set(string)) # Multiple ports

      # Optional - Timeouts
      timeouts = optional(object({
        create = optional(string, "30m")
        delete = optional(string, "30m")
        read   = optional(string, "5m")
        update = optional(string, "30m")
      }))
    })), {})

    # Optional - Timeouts
    timeouts = optional(object({
      create = optional(string, "30m")
      delete = optional(string, "30m")
      read   = optional(string, "5m")
      update = optional(string, "30m")
    }))

    # Tags
    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of Network Security Groups to create with all AVM module options exposed"
}

variable "vm_foundation" {
  type = map(object({
    # Required - Resource Reference
    rg_key = string

    # Required - OS Configuration
    os_type = string # "Windows" or "Linux"

    # Optional - Basic Configuration
    name             = optional(string)
    location         = optional(string)
    zone             = optional(string) # Availability zone (1, 2, 3, or null)
    enable_telemetry = optional(bool, false)

    # Optional - VM Size (cost-efficient default)
    sku_size = optional(string, "Standard_B2s") # Cost-efficient default, scale up as needed

    # Network Interfaces (required)
    network_interfaces = map(object({
      name = optional(string)

      ip_configurations = map(object({
        name = optional(string)

        # Subnet - use either resource ID or key references
        private_ip_subnet_resource_id = optional(string)
        vnet_key                      = optional(string) # Reference to vnet_foundation
        subnet_key                    = optional(string) # Reference to subnet within vnet

        # Private IP
        private_ip_address            = optional(string)
        private_ip_address_allocation = optional(string, "Dynamic")
        is_primary_ipconfiguration    = optional(bool)

        # Public IP - disabled by default for security
        create_public_ip_address                       = optional(bool, false) # Secure default
        public_ip_address_name                         = optional(string)
        public_ip_address_resource_id                  = optional(string)
        public_ip_address_allocation                   = optional(string, "Static")
        public_ip_address_sku                          = optional(string, "Standard")
        public_ip_address_availability_zone            = optional(string, "Zone-Redundant")
        public_ip_address_idle_timeout_in_minutes      = optional(number)
        public_ip_address_ip_version                   = optional(string, "IPv4")
        public_ip_address_sku_tier                     = optional(string, "Regional")
        public_ip_address_lock                         = optional(object({ kind = string, name = optional(string) }))
        public_ip_address_tags                         = optional(map(string))
        public_ip_address_inherit_tags                 = optional(bool, true)
        public_ip_address_ddos_protection_mode         = optional(string)
        public_ip_address_ddos_protection_plan_id      = optional(string)
        public_ip_address_domain_name_label            = optional(string)
        public_ip_address_domain_name_label_scope      = optional(string)
        public_ip_address_edge_zone                    = optional(string)
        public_ip_address_ip_tags                      = optional(map(string))
        public_ip_address_public_ip_prefix_resource_id = optional(string)
        public_ip_address_reverse_fqdn                 = optional(string)
        public_ip_address_diagnostic_settings          = optional(map(any))
        public_ip_address_role_assignments             = optional(map(any))
      }))

      # NIC-level settings
      accelerated_networking_enabled     = optional(bool, true)
      dns_servers                        = optional(list(string))
      edge_zone                          = optional(string)
      internal_dns_name_label            = optional(string)
      ip_forwarding_enabled              = optional(bool, false)
      network_security_group_resource_id = optional(string)
      nsg_key                            = optional(string) # Reference to nsg_foundation
      lock                               = optional(object({ kind = string, name = optional(string) }))
      role_assignments                   = optional(map(any))
      diagnostic_settings                = optional(map(any))
      inherit_tags                       = optional(bool, true)
      tags                               = optional(map(string))
    }))

    # Source Image
    source_image_reference = optional(object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    }))
    source_image_resource_id = optional(string) # Use custom image instead of marketplace

    # OS Disk
    os_disk = optional(object({
      caching                          = optional(string, "ReadWrite")
      storage_account_type             = optional(string, "Premium_LRS")
      name                             = optional(string)
      disk_size_gb                     = optional(number)
      write_accelerator_enabled        = optional(bool, false)
      secure_vm_disk_encryption_set_id = optional(string)
      security_encryption_type         = optional(string)
      disk_encryption_set_id           = optional(string)
    }))

    # Security - Secure defaults
    encryption_at_host_enabled = optional(bool, true) # Secure default - encrypt all disks
    secure_boot_enabled        = optional(bool)
    vtpm_enabled               = optional(bool)

    # Account Credentials
    account_credentials = optional(object({
      admin_username                                 = optional(string)
      admin_password                                 = optional(string)
      admin_ssh_keys                                 = optional(set(object({ public_key = string, username = optional(string) })))
      disable_password_authentication                = optional(bool, true) # Secure default for Linux
      generate_admin_password_or_ssh_key             = optional(bool, true)
      generated_secrets_key_vault_secret_resource_id = optional(string)
      generated_secrets_key_vault_secret_config      = optional(object({ name = string, expiration_date = optional(string), content_type = optional(string), not_before_date = optional(string), tags = optional(map(string)) }))
    }))

    # Managed Identity - Secure default enables system-assigned
    managed_identities = optional(object({
      system_assigned            = optional(bool, true) # Secure default
      user_assigned_resource_ids = optional(set(string))
    }))

    # Data Disks
    data_disk_managed_disks = optional(map(object({
      name                             = string
      storage_account_type             = string
      caching                          = optional(string, "ReadWrite")
      create_option                    = optional(string, "Empty")
      disk_size_gb                     = optional(number)
      lun                              = optional(number)
      write_accelerator_enabled        = optional(bool, false)
      disk_encryption_set_id           = optional(string)
      secure_vm_disk_encryption_set_id = optional(string)
      security_encryption_type         = optional(string)
      disk_iops_read_write             = optional(number)
      disk_mbps_read_write             = optional(number)
      lock                             = optional(object({ kind = string, name = optional(string) }))
      role_assignments                 = optional(map(any))
      tags                             = optional(map(string))
      inherit_tags                     = optional(bool, true)
    })), {})

    # Extensions
    extensions = optional(map(object({
      name                        = string
      publisher                   = string
      type                        = string
      type_handler_version        = string
      auto_upgrade_minor_version  = optional(bool, true)
      automatic_upgrade_enabled   = optional(bool, false)
      failure_suppression_enabled = optional(bool, false)
      settings                    = optional(string)
      protected_settings          = optional(string)
      provision_after_extensions  = optional(list(string))
      tags                        = optional(map(string))
    })), {})

    # Run Commands
    run_commands = optional(map(object({
      name                 = string
      source_script        = optional(string)
      source_script_uri    = optional(string)
      source_command_id    = optional(string)
      error_blob_uri       = optional(string)
      output_blob_uri      = optional(string)
      run_as_user          = optional(string)
      run_as_password      = optional(string)
      parameters           = optional(list(object({ name = string, value = string })))
      protected_parameters = optional(list(object({ name = string, value = string })))
      tags                 = optional(map(string))
    })), {})

    # Boot Diagnostics
    boot_diagnostics                     = optional(bool, false)
    boot_diagnostics_storage_account_uri = optional(string)

    # Priority (Regular or Spot for cost savings)
    priority        = optional(string, "Regular")
    eviction_policy = optional(string) # Required for Spot VMs
    max_bid_price   = optional(number) # For Spot VMs

    # Patching
    patch_mode                                             = optional(string)
    patch_assessment_mode                                  = optional(string)
    bypass_platform_safety_checks_on_user_schedule_enabled = optional(bool)
    hotpatching_enabled                                    = optional(bool)

    # Availability
    availability_set_resource_id           = optional(string)
    capacity_reservation_group_resource_id = optional(string)
    dedicated_host_resource_id             = optional(string)
    dedicated_host_group_resource_id       = optional(string)
    proximity_placement_group_resource_id  = optional(string)
    virtual_machine_scale_set_resource_id  = optional(string)
    platform_fault_domain                  = optional(number)

    # Shutdown Schedule (cost savings)
    shutdown_schedules = optional(map(object({
      daily_recurrence_time = string
      timezone              = string
      enabled               = optional(bool, true)
      notification_settings = optional(object({
        enabled         = optional(bool, false)
        email           = optional(string)
        time_in_minutes = optional(number, 30)
        webhook_url     = optional(string)
      }))
      tags = optional(map(string))
    })), {})

    # Backup
    azure_backup_configurations = optional(map(object({
      resource_group_name       = string
      recovery_vault_name       = string
      backup_policy_resource_id = string
      exclude_disk_luns         = optional(list(number))
      include_disk_luns         = optional(list(number))
      protection_stopped        = optional(bool, false)
    })), {})

    # Resource Lock
    lock = optional(object({
      kind = string # "CanNotDelete" or "ReadOnly"
      name = optional(string)
    }))

    # Role Assignments
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

    # Diagnostic Settings
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

    # Timeouts
    timeouts = optional(object({
      create = optional(string, "45m")
      delete = optional(string, "45m")
      read   = optional(string, "5m")
      update = optional(string, "45m")
    }))

    # Tags
    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of Virtual Machines to create with all AVM module options exposed"
}

variable "app_foundation" {
  type = map(object({
    # Optional - Basic Configuration
    display_name = optional(string) # Defaults to "app-{suffix}-{key}"
    description  = optional(string)
    notes        = optional(string)
    owners       = optional(list(string)) # Defaults to current user

    # Security - Secure defaults
    sign_in_audience               = optional(string, "AzureADMyOrg") # Secure default - single tenant only
    fallback_public_client_enabled = optional(bool, false)            # Secure default - no public client
    device_only_auth_enabled       = optional(bool, false)
    oauth2_post_response_required  = optional(bool, false)
    prevent_duplicate_names        = optional(bool, true)

    # Optional - Identifier URIs
    identifier_uris              = optional(set(string))
    service_management_reference = optional(string)
    logo_image                   = optional(string) # Base64 encoded image

    # Optional - Group Membership Claims
    group_membership_claims = optional(list(string)) # "All", "ApplicationGroup", "DirectoryRole", "None", "SecurityGroup"

    # Optional - Tags (Azure AD application tags)
    app_tags = optional(set(string))

    # Optional - Feature Tags
    feature_tags = optional(object({
      custom_single_sign_on = optional(bool)
      enterprise            = optional(bool)
      gallery               = optional(bool)
      hide                  = optional(bool)
    }))

    # Optional - API Configuration
    api = optional(object({
      known_client_applications      = optional(set(string))
      mapped_claims_enabled          = optional(bool)
      requested_access_token_version = optional(number, 2) # v2 tokens recommended

      oauth2_permission_scopes = optional(map(object({
        id                         = string
        value                      = string
        admin_consent_display_name = optional(string)
        admin_consent_description  = optional(string)
        user_consent_display_name  = optional(string)
        user_consent_description   = optional(string)
        enabled                    = optional(bool, true)
        type                       = optional(string, "User") # "Admin" or "User"
      })))
    }))

    # Optional - App Roles
    app_roles = optional(map(object({
      id                   = string
      display_name         = string
      value                = optional(string)
      description          = optional(string)
      allowed_member_types = list(string) # ["User"], ["Application"], or ["User", "Application"]
      enabled              = optional(bool, true)
    })))

    # Optional - Optional Claims
    optional_claims = optional(object({
      access_token = optional(list(object({
        name                  = string
        additional_properties = optional(list(string))
        essential             = optional(bool, false)
        source                = optional(string)
      })))
      id_token = optional(list(object({
        name                  = string
        additional_properties = optional(list(string))
        essential             = optional(bool, false)
        source                = optional(string)
      })))
      saml2_token = optional(list(object({
        name                  = string
        additional_properties = optional(list(string))
        essential             = optional(bool, false)
        source                = optional(string)
      })))
    }))

    # Optional - Public Client (Native/Mobile apps)
    public_client = optional(object({
      redirect_uris = optional(set(string))
    }))

    # Optional - Required Resource Access (API Permissions)
    required_resource_access = optional(map(object({
      resource_app_id = string # e.g., "00000003-0000-0000-c000-000000000000" for Microsoft Graph
      resource_access = map(object({
        id   = string
        type = string # "Role" (application) or "Scope" (delegated)
      }))
    })))

    # Optional - Single Page Application
    single_page_application = optional(object({
      redirect_uris = optional(set(string))
    }))

    # Optional - Web Application
    web = optional(object({
      homepage_url  = optional(string)
      logout_url    = optional(string)
      redirect_uris = optional(set(string))
      implicit_grant = optional(object({
        access_token_issuance_enabled = optional(bool, false) # Secure default - disabled
        id_token_issuance_enabled     = optional(bool, false) # Secure default - disabled
      }))
    }))

    # Optional - Password Credentials (prefer managed identity or certificates)
    passwords = optional(map(object({
      display_name = string
      start_date   = optional(string)
      end_date     = optional(string)
    })))

    # Service Principal Configuration
    create_service_principal       = optional(bool, true)
    service_principal_description  = optional(string)
    service_principal_enabled      = optional(bool, true)
    app_role_assignment_required   = optional(bool, false)
    service_principal_notes        = optional(string)
    login_url                      = optional(string)
    notification_email_addresses   = optional(set(string))
    service_principal_owners       = optional(list(string))
    use_existing_service_principal = optional(bool, false)
    service_principal_tags         = optional(set(string))

    service_principal_feature_tags = optional(object({
      custom_single_sign_on = optional(bool)
      enterprise            = optional(bool)
      gallery               = optional(bool)
      hide                  = optional(bool)
    }))

    saml_single_sign_on = optional(object({
      relay_state = optional(string)
    }))

    # Federated Identity Credentials (for workload identity - GitHub Actions, Kubernetes, etc.)
    federated_identity_credentials = optional(map(object({
      display_name = string
      description  = optional(string)
      audiences    = list(string)
      issuer       = string # e.g., "https://token.actions.githubusercontent.com" for GitHub
      subject      = string # e.g., "repo:org/repo:ref:refs/heads/main"
    })))
  }))
  default     = {}
  description = "Map of Azure AD Applications to create with service principals and optional federated identity credentials"
}

variable "aks_foundation" {
  type = map(object({
    # Required - Resource Reference
    rg_key = string

    # Optional - Basic Configuration
    name             = optional(string)
    location         = optional(string)
    enable_telemetry = optional(bool, false)
    dns_prefix       = optional(string)

    # Kubernetes Version
    kubernetes_version = optional(string) # null = latest stable

    # SKU Configuration
    sku = optional(object({
      name = optional(string, "Base")
      tier = optional(string, "Free") # "Free" or "Standard" (production SLA)
    }))

    # Auto-upgrade Profile - Secure default
    auto_upgrade_profile = optional(object({
      upgrade_channel = optional(string, "patch") # "none", "patch", "rapid", "stable", "node-image"
    }))

    # Node Resource Group
    node_resource_group = optional(string)
    node_resource_group_profile = optional(object({
      restricted_mode = optional(bool, true) # Secure default - restrict node RG modifications
    }))

    # Default Agent Pool (note: AVM uses default_agent_pool not default_node_pool)
    default_agent_pool = optional(object({
      name                         = optional(string, "system")
      vm_size                      = optional(string, "Standard_D2s_v3") # Cost-efficient default
      node_count                   = optional(number, 1)
      only_critical_addons_enabled = optional(bool, true) # Secure default - system pods only
      temporary_name_for_rotation  = optional(string, "temp")
      auto_scaling_enabled         = optional(bool, true)
      min_count                    = optional(number, 1)
      max_count                    = optional(number, 3)
      os_sku                       = optional(string, "AzureLinux") # Secure default
      os_disk_size_gb              = optional(number)
      os_disk_type                 = optional(string, "Managed")
      ultra_ssd_enabled            = optional(bool, false)
      zones                        = optional(list(string), ["1", "2", "3"])
      max_pods                     = optional(number, 30)
      node_labels                  = optional(map(string))
      node_taints                  = optional(list(string))
      vnet_subnet_id               = optional(string)
      vnet_key                     = optional(string) # Reference to vnet_foundation
      subnet_key                   = optional(string) # Reference to subnet within vnet
      pod_subnet_id                = optional(string)
      enable_host_encryption       = optional(bool, true) # Secure default
      fips_enabled                 = optional(bool, false)
      kubelet_disk_type            = optional(string)
      orchestrator_version         = optional(string)
      proximity_placement_group_id = optional(string)
      scale_down_mode              = optional(string, "Delete")
      snapshot_id                  = optional(string)
      workload_runtime             = optional(string)
      upgrade_settings = optional(object({
        max_surge = optional(string, "10%")
      }))
      kubelet_config  = optional(any)
      linux_os_config = optional(any)
    }))

    # Network Profile - Secure defaults
    network_profile = optional(object({
      network_plugin      = optional(string, "azure")
      network_policy      = optional(string, "azure") # Secure default - enable network policies
      network_plugin_mode = optional(string, "overlay")
      outbound_type       = optional(string, "loadBalancer") # Secure default
      load_balancer_sku   = optional(string, "standard")
      service_cidr        = optional(string, "10.0.0.0/16")
      dns_service_ip      = optional(string, "10.0.0.10")
      pod_cidr            = optional(string)
      network_data_plane  = optional(string)
      load_balancer_profile = optional(object({
        managed_outbound_ip_count   = optional(number)
        outbound_ip_address_ids     = optional(list(string))
        outbound_ip_prefix_ids      = optional(list(string))
        outbound_ports_allocated    = optional(number)
        idle_timeout_in_minutes     = optional(number)
        managed_outbound_ipv6_count = optional(number)
      }))
      nat_gateway_profile = optional(object({
        managed_outbound_ip_count = optional(number)
        idle_timeout_in_minutes   = optional(number)
      }))
    }))

    # API Server Access Profile
    api_server_access_profile = optional(object({
      authorized_ip_ranges = optional(list(string)) # Secure - restrict API server access
    }))

    # Managed Identity - Secure default
    managed_identities = optional(object({
      system_assigned            = optional(bool, true) # Secure default
      user_assigned_resource_ids = optional(set(string))
    }))

    # Azure AD Profile - Secure defaults (note: AVM uses aad_profile)
    aad_profile = optional(object({
      azure_rbac_enabled     = optional(bool, true) # Secure default
      managed                = optional(bool, true) # Secure default
      admin_group_object_ids = optional(list(string), [])
      tenant_id              = optional(string)
    }))

    # Disable Local Accounts - Secure default (note: AVM uses disable_local_accounts)
    disable_local_accounts = optional(bool, true) # Secure default

    # Enable RBAC
    enable_rbac = optional(bool, true) # Secure default

    # Security Profile
    security_profile = optional(object({
      defender = optional(object({
        log_analytics_workspace_resource_id = string
      }))
      workload_identity_enabled = optional(bool, true) # Secure default
      image_cleaner = optional(object({
        enabled        = optional(bool, true)
        interval_hours = optional(number, 48)
      }))
    }))

    # Azure Policy Addon - Secure default (note: AVM uses addon_profile_azure_policy)
    addon_profile_azure_policy = optional(object({
      enabled = optional(bool, true) # Secure default
    }))

    # Azure Monitor Profile
    azure_monitor_profile = optional(object({
      metrics = optional(object({
        enabled                        = optional(bool, true)
        annotations_allowed            = optional(string)
        labels_allowed                 = optional(string)
        kube_state_metrics_annotations = optional(string)
        kube_state_metrics_labels      = optional(string)
      }))
    }))

    # OMS Agent (Container Insights) - note: AVM uses addon_profile_oms_agent
    addon_profile_oms_agent = optional(object({
      enabled                    = optional(bool, true)
      log_analytics_workspace_id = string
    }))
    log_analytics_workspace_resource_id = optional(string) # Convenience field

    # Key Vault Secrets Provider - note: AVM uses addon_profile_key_vault_secrets_provider
    addon_profile_key_vault_secrets_provider = optional(object({
      enabled                  = optional(bool, true)
      secret_rotation_enabled  = optional(bool, true) # Secure default
      secret_rotation_interval = optional(string, "2m")
    }))

    # OIDC Issuer Profile - Required for workload identity
    oidc_issuer_profile = optional(object({
      enabled = optional(bool, true) # Secure default for workload identity
    }))

    # Public Network Access
    public_network_access = optional(string, "Enabled") # "Enabled" or "Disabled"

    # Private Endpoints
    private_endpoints = optional(map(object({
      name                            = optional(string)
      subnet_resource_id              = optional(string)
      subnet_key                      = optional(string)
      vnet_key                        = optional(string)
      pdz_key                         = optional(string)
      private_dns_zone_group_name     = optional(string, "default")
      private_dns_zone_resource_ids   = optional(set(string))
      private_service_connection_name = optional(string)
      network_interface_name          = optional(string)
      location                        = optional(string)
      resource_group_name             = optional(string)
      ip_configurations = optional(map(object({
        name               = string
        private_ip_address = optional(string)
      })), {})
      tags = optional(map(string))
      lock = optional(object({
        kind = string
        name = optional(string)
      }))
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
    })), {})
    private_endpoints_manage_dns_zone_group = optional(bool, true)

    # Disk Encryption
    disk_encryption_set_id = optional(string)

    # HTTP Proxy
    http_proxy_config = optional(object({
      http_proxy  = optional(string)
      https_proxy = optional(string)
      no_proxy    = optional(list(string))
      trusted_ca  = optional(string)
    }))

    # Ingress Profile
    ingress_profile = optional(object({
      web_app_routing = optional(object({
        dns_zone_resource_id = optional(string)
      }))
    }))

    # Linux Profile
    linux_profile = optional(object({
      admin_username = string
      ssh_key = object({
        key_data = string
      })
    }))

    # Windows Profile
    windows_profile = optional(object({
      admin_username = string
      license        = optional(string)
    }))
    windows_profile_password = optional(string)

    # Service Mesh (Istio)
    service_mesh_profile = optional(object({
      mode                             = string # "Istio"
      external_ingress_gateway_enabled = optional(bool, false)
      internal_ingress_gateway_enabled = optional(bool, false)
    }))

    # Storage Profile
    storage_profile = optional(object({
      blob_driver_enabled         = optional(bool, false)
      disk_driver_enabled         = optional(bool, true)
      file_driver_enabled         = optional(bool, true)
      snapshot_controller_enabled = optional(bool, true)
    }))

    # Auto-scaler Profile
    auto_scaler_profile = optional(object({
      balance_similar_node_groups      = optional(bool, false)
      empty_bulk_delete_max            = optional(number, 10)
      expander                         = optional(string, "random")
      max_graceful_termination_sec     = optional(number, 600)
      max_node_provisioning_time       = optional(string, "15m")
      max_unready_nodes                = optional(number, 3)
      max_unready_percentage           = optional(number, 45)
      new_pod_scale_up_delay           = optional(string, "10s")
      scale_down_delay_after_add       = optional(string, "10m")
      scale_down_delay_after_delete    = optional(string, "10s")
      scale_down_delay_after_failure   = optional(string, "3m")
      scale_down_unneeded              = optional(string, "10m")
      scale_down_unready               = optional(string, "20m")
      scale_down_utilization_threshold = optional(number, 0.5)
      scan_interval                    = optional(string, "10s")
      skip_nodes_with_local_storage    = optional(bool, true)
      skip_nodes_with_system_pods      = optional(bool, true)
    }))

    # Workload Auto-scaler (KEDA/VPA) - note: AVM uses workload_auto_scaler_profile
    workload_auto_scaler_profile = optional(object({
      keda_enabled                    = optional(bool, false)
      vertical_pod_autoscaler_enabled = optional(bool, false)
    }))

    # Pod Identity Profile
    pod_identity_profile = optional(object({
      enabled                      = optional(bool, false)
      allow_network_plugin_kubenet = optional(bool, false)
    }))

    # Resource Lock
    lock = optional(object({
      kind = string # "CanNotDelete" or "ReadOnly"
      name = optional(string)
    }))

    # Role Assignments
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

    # Diagnostic Settings
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

    # Tags
    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of Azure Kubernetes Service clusters to create with all AVM module options exposed"
}

variable "pdz_foundation" {
  type = map(object({
    # Required - Resource References
    rg_key = string

    # Required - Domain Configuration
    domain_name = string

    # Optional - Basic Configuration
    enable_telemetry = optional(bool, false)

    # Note: lock not supported in module version 0.4.3

    # Optional - Role Assignments
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

    # Optional - SOA Record
    soa_record = optional(object({
      email        = string
      name         = optional(string, "@")
      expire_time  = optional(number, 2419200)
      minimum_ttl  = optional(number, 10)
      refresh_time = optional(number, 3600)
      retry_time   = optional(number, 300)
      ttl          = optional(number, 3600)
    }))

    # Optional - A Records
    a_records = optional(map(object({
      name         = string
      ttl          = number
      records      = optional(list(string))
      ip_addresses = optional(set(string))
    })))

    # Optional - AAAA Records
    aaaa_records = optional(map(object({
      name         = string
      ttl          = number
      records      = optional(list(string))
      ip_addresses = optional(set(string))
    })))

    # Optional - CNAME Records
    cname_records = optional(map(object({
      name   = string
      ttl    = number
      record = optional(string)
      cname  = optional(string)
    })))

    # Optional - MX Records
    mx_records = optional(map(object({
      name = optional(string, "@")
      ttl  = number
      records = map(object({
        preference = number
        exchange   = string
      }))
    })))

    # Optional - PTR Records
    ptr_records = optional(map(object({
      name         = string
      ttl          = number
      records      = optional(list(string))
      domain_names = optional(set(string))
    })))

    # Optional - SRV Records
    srv_records = optional(map(object({
      name = string
      ttl  = number
      records = map(object({
        priority = number
        weight   = number
        port     = number
        target   = string
      }))
    })))

    # Optional - TXT Records
    txt_records = optional(map(object({
      name = string
      ttl  = number
      records = map(object({
        value = list(string)
      }))
    })))

    # Virtual Network Links
    virtual_network_links = optional(map(object({
      name                                   = optional(string)
      vnetlinkname                           = optional(string)
      vnet_key                               = optional(string) # Reference to vnet_foundation
      vnetid                                 = optional(string) # Direct vnet resource ID
      virtual_network_id                     = optional(string) # Alias for vnetid
      autoregistration                       = optional(bool, false)
      registration_enabled                   = optional(bool) # Alias for autoregistration
      private_dns_zone_supports_private_link = optional(bool, false)
      resolution_policy                      = optional(string, "Default") # "Default" or "NxDomainRedirect"
      tags                                   = optional(map(string))
    })))

    # Optional - Timeouts
    timeouts = optional(object({
      dns_zones = optional(object({
        create = optional(string, "30m")
        delete = optional(string, "30m")
        update = optional(string, "30m")
        read   = optional(string, "5m")
      }))
      vnet_links = optional(object({
        create = optional(string, "30m")
        delete = optional(string, "30m")
        update = optional(string, "30m")
        read   = optional(string, "5m")
      }))
    }))

    # Optional - Retry Configuration
    retry = optional(object({
      error_message_regex  = optional(list(string), ["ReferencedResourceNotProvisioned", "CannotDeleteResource"])
      interval_seconds     = optional(number, 10)
      max_interval_seconds = optional(number, 180)
      multiplier           = optional(number, 1.5)
      randomization_factor = optional(number, 0.5)
    }))

    # Tags
    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of Private DNS Zones to create with all AVM module options exposed"
}

variable "location_short" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "project_name" {
  type = string
}

variable "module_name" {
  type = string
}