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
        private_ip_subnet_resource_id = optional(string) # Subnet resource ID
        private_ip_address            = optional(string)
        private_ip_address_allocation = optional(string, "Dynamic")
        private_ip_address_version    = optional(string, "IPv4")
        is_primary_ipconfiguration    = optional(bool, true)

        # Public IP - disabled by default for security
        create_public_ip_address      = optional(bool, false)
        public_ip_address_name        = optional(string)
        public_ip_address_resource_id = optional(string)
        public_ip_address_lock_name   = optional(string)

        # Load Balancer / App Gateway integration
        app_gateway_backend_pools = optional(map(object({
          app_gateway_backend_pool_resource_id = string
        })), {})
        gateway_load_balancer_frontend_ip_configuration_resource_id = optional(string)
        load_balancer_backend_pools = optional(map(object({
          load_balancer_backend_pool_resource_id = string
        })), {})
        load_balancer_nat_rules = optional(map(object({
          load_balancer_nat_rule_resource_id = string
        })), {})
      }))

      # NIC-level settings
      accelerated_networking_enabled = optional(bool, false)
      application_security_groups = optional(map(object({
        application_security_group_resource_id = string
      })), {})
      dns_servers             = optional(list(string))
      edge_zone               = optional(string)
      inherit_tags            = optional(bool, true)
      internal_dns_name_label = optional(string)
      ip_forwarding_enabled   = optional(bool, false)
      is_primary              = optional(bool, false)
      lock_level              = optional(string)
      lock_name               = optional(string)
      network_security_groups = optional(map(object({
        network_security_group_resource_id = string
      })), {})
      resource_group_name = optional(string)
      role_assignments    = optional(map(any))
      diagnostic_settings = optional(map(any))
      tags                = optional(map(string))
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
      diff_disk_settings = optional(object({
        option    = string
        placement = optional(string, "CacheDisk")
      }))
    }))

    # Security - Secure defaults
    encryption_at_host_enabled = optional(bool, true) # Encrypt all disks at host level
    secure_boot_enabled        = optional(bool)
    vtpm_enabled               = optional(bool)

    # Account Credentials
    account_credentials = optional(object({
      admin_credentials = optional(object({
        username                           = optional(string, "azureuser")
        password                           = optional(string)
        ssh_keys                           = optional(list(string), [])
        generate_admin_password_or_ssh_key = optional(bool, true)
      }), {})
      key_vault_configuration = optional(object({
        resource_id = string
        secret_configuration = optional(object({
          name                           = optional(string)
          expiration_date_length_in_days = optional(number, 45)
          content_type                   = optional(string, "text/plain")
          not_before_date                = optional(string)
          tags                           = optional(map(string), {})
        }), {})
      }))
      password_authentication_disabled = optional(bool, true) # Secure default for Linux
    }), {})

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
      managed_disk_resource_id      = string
      caching                       = string
      lun                           = number
      disk_attachment_create_option = optional(string, "Attach")
      write_accelerator_enabled     = optional(bool, false)
    })), {})

    # Extensions
    extensions = optional(map(object({
      name                        = string
      publisher                   = string
      type                        = string
      type_handler_version        = string
      auto_upgrade_minor_version  = optional(bool)
      automatic_upgrade_enabled   = optional(bool)
      deploy_sequence             = optional(number, 5)
      failure_suppression_enabled = optional(bool, false)
      settings                    = optional(string)
      protected_settings          = optional(string)
      protected_settings_from_key_vault = optional(object({
        secret_url      = string
        source_vault_id = string
      }))
      provision_after_extensions = optional(list(string), [])
      tags                       = optional(map(string))
      timeouts = optional(object({
        create = optional(string)
        delete = optional(string)
        update = optional(string)
        read   = optional(string)
      }))
    })), {})
    extensions_time_budget     = optional(string)
    allow_extension_operations = optional(bool)

    # Run Commands
    run_commands = optional(map(object({
      location        = string
      name            = string
      deploy_sequence = optional(number, 3)
      script_source = object({
        command_id = optional(string)
        script     = optional(string)
        script_uri = optional(string)
        script_uri_managed_identity = optional(object({
          client_id = optional(string)
          object_id = optional(string)
        }))
      })
      error_blob_managed_identity = optional(object({
        client_id = optional(string)
        object_id = optional(string)
      }))
      error_blob_uri = optional(string)
      output_blob_managed_identity = optional(object({
        client_id = optional(string)
        object_id = optional(string)
      }))
      output_blob_uri = optional(string)
      parameters = optional(map(object({
        name  = string
        value = string
      })), {})
      timeouts = optional(object({
        create = optional(string)
        delete = optional(string)
        update = optional(string)
        read   = optional(string)
      }))
      tags = optional(map(string))
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
        time_in_minutes = optional(string, "30")
        webhook_url     = optional(string)
      }), { enabled = false })
      tags = optional(map(string))
    })), {})

    # Backup
    azure_backup_configurations = optional(map(object({
      recovery_vault_resource_id = string
      resource_group_name        = optional(string)
      recovery_vault_name        = optional(string)
      backup_policy_resource_id  = optional(string)
      exclude_disk_luns          = optional(list(number))
      include_disk_luns          = optional(list(number))
    })), {})

    # Maintenance Configuration
    maintenance_configuration_resource_ids = optional(map(string), {})

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
      role_definition_id_or_name             = string
      scope_resource_id                      = string
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
      log_groups                               = optional(set(string), [])
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

variable "public_ip_configuration_details" {
  type = object({
    allocation_method       = optional(string, "Static")
    ddos_protection_mode    = optional(string, "VirtualNetworkInherited")
    ddos_protection_plan_id = optional(string)
    domain_name_label       = optional(string)
    idle_timeout_in_minutes = optional(number, 30)
    inherit_tags            = optional(bool, false)
    ip_version              = optional(string, "IPv4")
    lock_level              = optional(string)
    sku                     = optional(string, "Standard")
    sku_tier                = optional(string, "Regional")
    tags                    = optional(map(string))
    zones                   = optional(set(string), ["1", "2", "3"])
  })
  default     = {}
  description = "Global public IP configuration applied to all VMs that create public IPs via create_public_ip_address. Individual IP SKU, allocation method, zones, and DDoS settings are set here rather than per ip_configuration."
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
