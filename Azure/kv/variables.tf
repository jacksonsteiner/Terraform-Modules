variable "key_vaults" {
  type = map(object({
    # Required
    resource_group_name = string # Resource Group name where Key Vault will be created

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
    })), {})

    # Optional - Legacy Access Policies (disables RBAC)
    legacy_access_policies_enabled = optional(bool, false)
    legacy_access_policies = optional(map(object({
      object_id               = string
      application_id          = optional(string)
      certificate_permissions = optional(set(string), [])
      key_permissions         = optional(set(string), [])
      secret_permissions      = optional(set(string), [])
      storage_permissions     = optional(set(string), [])
    })), {})

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
    })), {})

    # Optional - Contacts
    contacts = optional(map(object({
      email = string
      name  = optional(string)
      phone = optional(string)
    })), {})

    # Optional - Private Endpoints
    private_endpoints_manage_dns_zone_group = optional(bool, true)
    private_endpoints = optional(map(object({
      name                                    = optional(string)
      subnet_resource_id                      = string # Subnet resource ID for private endpoint
      private_dns_zone_group_name             = optional(string, "default")
      private_dns_zone_resource_ids           = optional(set(string), [])
      application_security_group_associations = optional(map(string), {})
      private_service_connection_name         = optional(string)
      network_interface_name                  = optional(string)
      location                                = optional(string)
      resource_group_name                     = optional(string)
      ip_configurations = optional(map(object({
        name               = string
        private_ip_address = string
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
      })), {})
    })), {})

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
    })), {})

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
    })), {})
    secrets_value = optional(map(string)) # Sensitive - actual secret values

    # Optional - RBAC Wait Configuration
    wait_for_rbac_before_key_operations = optional(object({
      create  = optional(string, "30s")
      destroy = optional(string, "0s")
    }), {})
    wait_for_rbac_before_secret_operations = optional(object({
      create  = optional(string, "30s")
      destroy = optional(string, "0s")
    }), {})
    wait_for_rbac_before_contact_operations = optional(object({
      create  = optional(string, "30s")
      destroy = optional(string, "0s")
    }), {})

    # Tags
    tags = optional(map(string), {})
  }))
  default     = {}
  description = "Map of Key Vaults to create with all AVM module options exposed"
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
