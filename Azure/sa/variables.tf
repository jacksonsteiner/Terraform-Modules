variable "storage_accounts" {
  type = map(object({
    # Required
    resource_group_name = string

    # Optional - Basic Configuration
    name             = optional(string)
    location         = optional(string)
    enable_telemetry = optional(bool, false)

    # Optional - Account Configuration
    account_kind                     = optional(string, "StorageV2") # "BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"
    account_tier                     = optional(string, "Standard")  # "Standard" or "Premium"
    account_replication_type         = optional(string, "LRS")       # "LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS" - LRS is cost-efficient default
    access_tier                      = optional(string, "Hot")       # "Hot", "Cool", "Cold", "Premium"
    cross_tenant_replication_enabled = optional(bool, false)
    edge_zone                        = optional(string)
    allowed_copy_scope               = optional(string) # "AAD" or "PrivateLink"

    # Optional - Security
    https_traffic_only_enabled        = optional(bool, true)
    min_tls_version                   = optional(string, "TLS1_2")
    infrastructure_encryption_enabled = optional(bool, true)
    allow_nested_items_to_be_public   = optional(bool, false)
    shared_access_key_enabled         = optional(bool, false)
    default_to_oauth_authentication   = optional(bool, true)
    public_network_access_enabled     = optional(bool, false)

    # Optional - Features
    nfsv3_enabled      = optional(bool, false)
    sftp_enabled       = optional(bool, false)
    local_user_enabled = optional(bool, false)
    local_user = optional(map(object({
      home_directory       = optional(string)
      name                 = string
      ssh_key_enabled      = optional(bool)
      ssh_password_enabled = optional(bool)
      permission_scope = optional(list(object({
        resource_name = string
        service       = string
        permissions = object({
          create = optional(bool)
          delete = optional(bool)
          list   = optional(bool)
          read   = optional(bool)
          write  = optional(bool)
        })
      })))
      ssh_authorized_key = optional(list(object({
        description = optional(string)
        key         = string
      })))
    })), {})

    # Optional - Customer Managed Key
    customer_managed_key = optional(object({
      key_vault_resource_id = string
      key_name              = string
      key_version           = optional(string)
      user_assigned_identity = optional(object({
        resource_id = string
      }))
    }))

    # Optional - Managed Identity
    managed_identities = optional(object({
      system_assigned            = optional(bool, false)
      user_assigned_resource_ids = optional(set(string), [])
    }), {})

    # Optional - Network Rules (deny by default)
    network_rules = optional(object({
      bypass                     = optional(set(string), ["AzureServices"])
      default_action             = optional(string, "Deny")
      ip_rules                   = optional(set(string), [])
      virtual_network_subnet_ids = optional(set(string), [])
      private_link_access = optional(list(object({
        endpoint_resource_id = string
        endpoint_tenant_id   = optional(string)
      })))
    }))

    # Optional - Custom Domain / Routing / SAS Policy
    custom_domain = optional(object({
      name          = string
      use_subdomain = optional(bool)
    }))
    routing = optional(object({
      choice                      = optional(string, "MicrosoftRouting")
      publish_internet_endpoints  = optional(bool, false)
      publish_microsoft_endpoints = optional(bool, false)
    }))
    sas_policy = optional(object({
      expiration_action = optional(string, "Log")
      expiration_period = string
    }))

    # Optional - Azure Files Authentication
    azure_files_authentication = optional(object({
      directory_type                 = optional(string, "AADKERB")
      default_share_level_permission = optional(string)
      active_directory = optional(object({
        domain_guid         = string
        domain_name         = string
        domain_sid          = optional(string)
        forest_name         = optional(string)
        netbios_domain_name = optional(string)
        storage_sid         = optional(string)
      }))
    }))
    large_file_share_enabled = optional(bool)

    # Optional - Encryption
    queue_encryption_key_type = optional(string)
    table_encryption_key_type = optional(string)

    # Optional - Blob / Share / Queue / Static website properties (passed through as-is)
    blob_properties  = optional(any)
    share_properties = optional(any)
    queue_properties = optional(any, {})
    static_website = optional(map(object({
      error_404_document = optional(string)
      index_document     = optional(string)
    })))

    # Optional - Containers
    containers = optional(map(object({
      name                              = optional(string)
      public_access                     = optional(string, "None")
      metadata                          = optional(map(string))
      default_encryption_scope          = optional(string)
      deny_encryption_scope_override    = optional(bool)
      enable_nfs_v3_all_squash          = optional(bool)
      enable_nfs_v3_root_squash         = optional(bool)
      immutable_storage_with_versioning = optional(object({ enabled = bool }))
      role_assignments                  = optional(any, {})
    })), {})

    # Optional - Queues / Shares / Tables / Data Lake Filesystems
    queues                             = optional(any, {})
    shares                             = optional(any, {})
    tables                             = optional(any, {})
    storage_data_lake_gen2_filesystems = optional(any, {})
    is_hns_enabled                     = optional(bool, false)
    immutability_policy = optional(object({
      allow_protected_append_writes = bool
      period_since_creation_in_days = number
      state                         = string
    }))

    # Optional - Management Policy
    storage_management_policy_rule = optional(any, {})

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
    })), {})

    # Optional - Diagnostic Settings (account-level + per-service)
    diagnostic_settings       = optional(any, {})
    diagnostic_settings_blob  = optional(any, {})
    diagnostic_settings_file  = optional(any, {})
    diagnostic_settings_queue = optional(any, {})
    diagnostic_settings_table = optional(any, {})

    # Optional - Private Endpoints
    private_endpoints_manage_dns_zone_group = optional(bool, true)
    private_endpoints = optional(map(object({
      name                                    = optional(string)
      subnet_resource_id                      = string
      subresource_name                        = string # "blob", "dfs", "file", "queue", "table", "web"
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

    # Tags
    tags = optional(map(string), {})
  }))
  default     = {}
  description = "Map of Storage Accounts to create with all AVM module options exposed"
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
