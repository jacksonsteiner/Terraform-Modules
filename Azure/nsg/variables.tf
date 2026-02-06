variable "network_security_groups" {
  type = map(object({
    # Required
    resource_group_name = string # Resource Group name where NSG will be created

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
        create = optional(string)
        delete = optional(string)
        read   = optional(string)
        update = optional(string)
      }))
    })), {})

    # Optional - Timeouts
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))

    # Tags
    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of Network Security Groups to create with all AVM module options exposed"
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
