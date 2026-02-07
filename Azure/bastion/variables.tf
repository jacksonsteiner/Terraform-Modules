variable "bastions" {
  type = map(object({
    # Required
    parent_id = string           # Resource Group ID where Bastion will be created
    subnet_id = optional(string) # Subnet ID (must be AzureBastionSubnet, required for non-Developer SKUs)

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
