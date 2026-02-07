variable "private_dns_zones" {
  type = map(object({
    # Required
    parent_id   = string # Resource Group ID where Private DNS Zone will be created
    domain_name = string

    # Optional - Basic Configuration
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

    # Optional - DNS Records
    a_records = optional(map(object({
      name         = string
      ttl          = number
      records      = optional(list(string))
      ip_addresses = optional(set(string))
    })))

    aaaa_records = optional(map(object({
      name         = string
      ttl          = number
      records      = optional(list(string))
      ip_addresses = optional(set(string))
    })))

    cname_records = optional(map(object({
      name   = string
      ttl    = number
      record = optional(string)
      cname  = optional(string)
    })))

    mx_records = optional(map(object({
      name = optional(string, "@")
      ttl  = number
      records = map(object({
        preference = number
        exchange   = string
      }))
    })))

    ptr_records = optional(map(object({
      name         = string
      ttl          = number
      records      = optional(list(string))
      domain_names = optional(set(string))
    })))

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
      vnetid                                 = optional(string) # Virtual Network resource ID
      virtual_network_id                     = optional(string) # Alias for vnetid
      autoregistration                       = optional(bool, false)
      registration_enabled                   = optional(bool) # Alias for autoregistration
      private_dns_zone_supports_private_link = optional(bool, false)
      resolution_policy                      = optional(string, "Default")
      tags                                   = optional(map(string))
    })))

    # Optional - Timeouts and Retry
    timeouts = optional(object({
      dns_zones = optional(object({
        create = optional(string)
        delete = optional(string)
        update = optional(string)
        read   = optional(string)
      }))
      vnet_links = optional(object({
        create = optional(string)
        delete = optional(string)
        update = optional(string)
        read   = optional(string)
      }))
    }))

    retry = optional(object({
      error_message_regex  = optional(list(string))
      interval_seconds     = optional(number)
      max_interval_seconds = optional(number)
      multiplier           = optional(number)
      randomization_factor = optional(number)
    }))

    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of Private DNS Zones to create with all AVM module options exposed"
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
