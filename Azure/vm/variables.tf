variable "virtual_machines" {
  type = map(object({
    # Required
    resource_group_name = string # Resource Group name where VM will be created

    # Optional - Basic Configuration
    name             = optional(string)
    location         = optional(string)
    zone             = optional(string) # Availability zone (1, 2, 3, or null for no zone)
    enable_telemetry = optional(bool, false)

    # Optional - OS Configuration
    os_type = optional(string, "Linux") # "Windows" or "Linux"

    # Optional - VM Size
    sku_size = optional(string, "Standard_D2s_v3") # Cost-efficient default

    # Network Interfaces (required - at least one)
    network_interfaces = map(object({
      name = optional(string)

      ip_configurations = map(object({
        name                          = optional(string)
        private_ip_subnet_resource_id = string # Subnet resource ID
        private_ip_address            = optional(string)
        private_ip_address_allocation = optional(string, "Dynamic")
        is_primary_ipconfiguration    = optional(bool)

        # Public IP - disabled by default for security
        create_public_ip_address                       = optional(bool, false)
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
    source_image_resource_id = optional(string)

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
    encryption_at_host_enabled = optional(bool, true) # Encrypt all disks at host level
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
      generated_secrets_key_vault_secret_config = optional(object({
        name            = string
        expiration_date = optional(string)
        content_type    = optional(string)
        not_before_date = optional(string)
        tags            = optional(map(string))
      }))
    }))

    # Managed Identity - Default enables system-assigned
    managed_identities = optional(object({
      system_assigned            = optional(bool, true)
      user_assigned_resource_ids = optional(set(string))
    }))

    # Custom Data
    custom_data = optional(string) # Base64-encoded custom data

    # Computer Name
    computer_name = optional(string)

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
    data_disk_existing_disks = optional(map(object({
      disk_resource_id = string
      caching          = optional(string, "ReadWrite")
      lun              = optional(number)
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
    extensions_time_budget     = optional(string)
    allow_extension_operations = optional(bool)

    # Run Commands
    run_commands = optional(map(object({
      name              = string
      source_script     = optional(string)
      source_script_uri = optional(string)
      source_command_id = optional(string)
      error_blob_uri    = optional(string)
      output_blob_uri   = optional(string)
      run_as_user       = optional(string)
      run_as_password   = optional(string)
      parameters        = optional(list(object({ name = string, value = string })))
      tags              = optional(map(string))
    })), {})
    run_commands_secrets = optional(map(any), {})

    # Boot Diagnostics - Enabled by default for monitoring
    boot_diagnostics                     = optional(bool, true)
    boot_diagnostics_storage_account_uri = optional(string)

    # Priority (Regular or Spot for cost savings)
    priority        = optional(string, "Regular") # "Regular" or "Spot"
    eviction_policy = optional(string)            # Required for Spot VMs
    max_bid_price   = optional(number)            # Maximum price for Spot VMs

    # Patching
    patch_mode                                             = optional(string)
    patch_assessment_mode                                  = optional(string)
    bypass_platform_safety_checks_on_user_schedule_enabled = optional(bool)
    hotpatching_enabled                                    = optional(bool)
    enable_automatic_updates                               = optional(bool)
    reboot_setting                                         = optional(string)

    # Availability
    availability_set_resource_id           = optional(string)
    capacity_reservation_group_resource_id = optional(string)
    dedicated_host_resource_id             = optional(string)
    dedicated_host_group_resource_id       = optional(string)
    proximity_placement_group_resource_id  = optional(string)
    virtual_machine_scale_set_resource_id  = optional(string)
    platform_fault_domain                  = optional(number)

    # Termination Notification (Spot VMs)
    termination_notification = optional(object({
      enabled = bool
      timeout = optional(string, "PT5M")
    }))

    # License
    license_type = optional(string) # BYOL license type

    # Plan (Marketplace image)
    plan = optional(object({
      name      = string
      product   = string
      publisher = string
    }))

    # Provision VM Agent
    provision_vm_agent = optional(bool)

    # Disk Controller
    disk_controller_type = optional(string) # "SCSI" or "NVMe"

    # Edge Zone
    edge_zone = optional(string)

    # Additional Unattend Contents (Windows)
    additional_unattend_contents = optional(list(object({
      content = string
      setting = string
    })))

    # Gallery Applications
    gallery_applications = optional(map(object({
      version_id             = string
      configuration_blob_uri = optional(string)
      order                  = optional(number, 0)
      tag                    = optional(string)
    })))

    # Secrets (Key Vault certificates)
    secrets = optional(list(object({
      key_vault_id = string
      certificate = set(object({
        url   = string
        store = optional(string)
      }))
    })))

    # Shutdown Schedule
    shutdown_schedules = optional(map(object({
      daily_recurrence_time = string # Time in HHmm format (e.g., "1900")
      timezone              = string # Timezone (e.g., "Eastern Standard Time")
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

    # Maintenance Configuration
    maintenance_configuration_resource_ids = optional(list(string))

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
    role_assignments_system_managed_identity = optional(map(object({
      role_definition_id_or_name       = string
      scope                            = string
      description                      = optional(string)
      skip_service_principal_aad_check = optional(bool, false)
      condition                        = optional(string)
      condition_version                = optional(string)
      principal_type                   = optional(string)
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
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))

    # Tags
    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of Virtual Machines to create with all AVM module options exposed"
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
