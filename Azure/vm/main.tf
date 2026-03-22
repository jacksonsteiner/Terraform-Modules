locals {
  suffix = join("-", compact([
    var.project_name, var.environment, var.location_short
  ]))

  names = {
    vm  = "vm-${local.suffix}"
    nic = "nic-${local.suffix}"
  }

  tags = {
    project     = var.project_name
    environment = var.environment
    location    = var.location
  }
}

module "virtual_machines" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "~> 0.20"

  for_each = var.virtual_machines

  # Required
  name                = coalesce(try(each.value.name, null), "${local.names.vm}-${each.key}")
  location            = coalesce(try(each.value.location, null), var.location)
  resource_group_name = each.value.resource_group_name
  zone                = try(each.value.zone, null)

  # OS Configuration - Linux is more secure default
  os_type  = coalesce(try(each.value.os_type, null), "Linux")
  sku_size = coalesce(try(each.value.sku_size, null), "Standard_D2s_v3")

  # Public IP global configuration (applies to all NICs that create public IPs)
  public_ip_configuration_details = var.public_ip_configuration_details

  # Optional - Telemetry
  enable_telemetry = coalesce(try(each.value.enable_telemetry, null), false)

  # Network Interfaces - complex passthrough with default naming
  network_interfaces = {
    for k, v in each.value.network_interfaces : k => {
      name = coalesce(try(v.name, null), "${local.names.nic}-${each.key}-${k}")

      ip_configurations = {
        for ipk, ipv in v.ip_configurations : ipk => {
          name                          = coalesce(try(ipv.name, null), ipk)
          private_ip_subnet_resource_id = try(ipv.private_ip_subnet_resource_id, null)
          private_ip_address            = try(ipv.private_ip_address, null)
          private_ip_address_allocation = try(ipv.private_ip_address_allocation, "Dynamic")
          private_ip_address_version    = try(ipv.private_ip_address_version, "IPv4")
          is_primary_ipconfiguration    = try(ipv.is_primary_ipconfiguration, true)

          # Public IP - disabled by default (secure)
          create_public_ip_address      = try(ipv.create_public_ip_address, false)
          public_ip_address_name        = try(ipv.public_ip_address_name, null)
          public_ip_address_resource_id = try(ipv.public_ip_address_resource_id, null)
          public_ip_address_lock_name   = try(ipv.public_ip_address_lock_name, null)

          # Load Balancer / App Gateway integration
          app_gateway_backend_pools                                   = try(ipv.app_gateway_backend_pools, {})
          gateway_load_balancer_frontend_ip_configuration_resource_id = try(ipv.gateway_load_balancer_frontend_ip_configuration_resource_id, null)
          load_balancer_backend_pools                                 = try(ipv.load_balancer_backend_pools, {})
          load_balancer_nat_rules                                     = try(ipv.load_balancer_nat_rules, {})
        }
      }

      # NIC-level settings
      accelerated_networking_enabled = try(v.accelerated_networking_enabled, false)
      application_security_groups    = try(v.application_security_groups, {})
      dns_servers                    = try(v.dns_servers, null)
      edge_zone                      = try(v.edge_zone, null)
      inherit_tags                   = try(v.inherit_tags, true)
      internal_dns_name_label        = try(v.internal_dns_name_label, null)
      ip_forwarding_enabled          = try(v.ip_forwarding_enabled, false)
      is_primary                     = try(v.is_primary, false)
      lock_level                     = try(v.lock_level, null)
      lock_name                      = try(v.lock_name, null)
      network_security_groups        = try(v.network_security_groups, {})
      resource_group_name            = try(v.resource_group_name, null)
      role_assignments               = try(v.role_assignments, {})
      diagnostic_settings            = try(v.diagnostic_settings, {})
      tags                           = try(v.tags, null)
    }
  }

  # Source Image
  source_image_reference   = try(each.value.source_image_reference, null)
  source_image_resource_id = try(each.value.source_image_resource_id, null)

  # OS Disk
  os_disk = {
    caching                          = try(each.value.os_disk.caching, "ReadWrite")
    storage_account_type             = try(each.value.os_disk.storage_account_type, "Premium_LRS")
    name                             = try(each.value.os_disk.name, null)
    disk_size_gb                     = try(each.value.os_disk.disk_size_gb, null)
    write_accelerator_enabled        = try(each.value.os_disk.write_accelerator_enabled, false)
    secure_vm_disk_encryption_set_id = try(each.value.os_disk.secure_vm_disk_encryption_set_id, null)
    security_encryption_type         = try(each.value.os_disk.security_encryption_type, null)
    disk_encryption_set_id           = try(each.value.os_disk.disk_encryption_set_id, null)
    diff_disk_settings               = try(each.value.os_disk.diff_disk_settings, null)
  }

  # Security - Secure defaults
  encryption_at_host_enabled = coalesce(try(each.value.encryption_at_host_enabled, null), true)
  secure_boot_enabled        = try(each.value.secure_boot_enabled, null)
  vtpm_enabled               = try(each.value.vtpm_enabled, null)

  # Account Credentials
  account_credentials = try(each.value.account_credentials, null)

  # Managed Identity - Secure default (system-assigned MI)
  managed_identities = try(each.value.managed_identities, {
    system_assigned = true
  })

  # Custom Data
  custom_data = try(each.value.custom_data, null)

  # Computer Name
  computer_name = try(each.value.computer_name, null)

  # Data Disks
  data_disk_managed_disks  = try(each.value.data_disk_managed_disks, {})
  data_disk_existing_disks = try(each.value.data_disk_existing_disks, {})

  # Extensions
  extensions                 = try(each.value.extensions, {})
  extensions_time_budget     = try(each.value.extensions_time_budget, null)
  allow_extension_operations = try(each.value.allow_extension_operations, null)

  # Run Commands
  run_commands         = try(each.value.run_commands, {})
  run_commands_secrets = try(each.value.run_commands_secrets, {})

  # Boot Diagnostics - Enabled by default for monitoring
  boot_diagnostics                     = coalesce(try(each.value.boot_diagnostics, null), true)
  boot_diagnostics_storage_account_uri = try(each.value.boot_diagnostics_storage_account_uri, null)

  # Priority (Regular or Spot)
  priority        = try(each.value.priority, "Regular")
  eviction_policy = try(each.value.eviction_policy, null)
  max_bid_price   = try(each.value.max_bid_price, null)

  # Patching
  patch_mode                                             = try(each.value.patch_mode, null)
  patch_assessment_mode                                  = try(each.value.patch_assessment_mode, null)
  bypass_platform_safety_checks_on_user_schedule_enabled = try(each.value.bypass_platform_safety_checks_on_user_schedule_enabled, null)
  hotpatching_enabled                                    = try(each.value.hotpatching_enabled, null)
  enable_automatic_updates                               = try(each.value.enable_automatic_updates, null)
  reboot_setting                                         = try(each.value.reboot_setting, null)

  # Availability
  availability_set_resource_id           = try(each.value.availability_set_resource_id, null)
  capacity_reservation_group_resource_id = try(each.value.capacity_reservation_group_resource_id, null)
  dedicated_host_resource_id             = try(each.value.dedicated_host_resource_id, null)
  dedicated_host_group_resource_id       = try(each.value.dedicated_host_group_resource_id, null)
  proximity_placement_group_resource_id  = try(each.value.proximity_placement_group_resource_id, null)
  virtual_machine_scale_set_resource_id  = try(each.value.virtual_machine_scale_set_resource_id, null)
  platform_fault_domain                  = try(each.value.platform_fault_domain, null)

  # Termination Notification
  termination_notification = try(each.value.termination_notification, null)

  # License
  license_type = try(each.value.license_type, null)

  # Plan (Marketplace image)
  plan = try(each.value.plan, null)

  # Provision VM Agent
  provision_vm_agent = try(each.value.provision_vm_agent, null)

  # Disk Controller
  disk_controller_type = try(each.value.disk_controller_type, null)

  # Edge Zone
  edge_zone = try(each.value.edge_zone, null)

  # Additional Unattend Contents (Windows)
  additional_unattend_contents = try(each.value.additional_unattend_contents, null)

  # Gallery Applications
  gallery_applications = try(each.value.gallery_applications, null)

  # Secrets (Key Vault certificates)
  secrets = try(each.value.secrets, null)

  # Shutdown Schedule
  shutdown_schedules = try(each.value.shutdown_schedules, {})

  # Backup
  azure_backup_configurations = try(each.value.azure_backup_configurations, {})

  # Maintenance Configuration
  maintenance_configuration_resource_ids = try(each.value.maintenance_configuration_resource_ids, null)

  # Resource Lock
  lock = try(each.value.lock, null)

  # Role Assignments
  role_assignments                         = try(each.value.role_assignments, {})
  role_assignments_system_managed_identity = try(each.value.role_assignments_system_managed_identity, {})

  # Diagnostic Settings
  diagnostic_settings = try(each.value.diagnostic_settings, {})

  # Timeouts
  timeouts = try(each.value.timeouts, null)

  # Tags
  tags = merge(local.tags, try(each.value.tags, {}))
}
