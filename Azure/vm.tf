module "vm_foundation" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.20.0"

  for_each = var.vm_foundation

  # Required
  name                = coalesce(try(each.value.name, null), "${local.names.vm}-${each.key}")
  location            = coalesce(try(each.value.location, null), var.location)
  resource_group_name = module.rg_foundation[each.value.rg_key].name
  zone                = try(each.value.zone, null)

  # Required - OS Configuration
  os_type  = each.value.os_type                                       # "Windows" or "Linux"
  sku_size = coalesce(try(each.value.sku_size, null), "Standard_B2s") # Cost-efficient default

  # Optional - Telemetry
  enable_telemetry = coalesce(try(each.value.enable_telemetry, null), false)

  # Network Interfaces
  network_interfaces = {
    for k, v in each.value.network_interfaces : k => {
      name = coalesce(try(v.name, null), "nic-${each.key}-${k}")

      ip_configurations = {
        for ipk, ipv in v.ip_configurations : ipk => {
          name                          = coalesce(try(ipv.name, null), ipk)
          private_ip_subnet_resource_id = coalesce(try(ipv.private_ip_subnet_resource_id, null), try(ipv.subnet_key, null) != null ? module.vnet_foundation[ipv.vnet_key].subnets[ipv.subnet_key].resource_id : null)
          private_ip_address            = try(ipv.private_ip_address, null)
          private_ip_address_allocation = try(ipv.private_ip_address_allocation, "Dynamic")
          is_primary_ipconfiguration    = try(ipv.is_primary_ipconfiguration, null)

          # Public IP Configuration
          create_public_ip_address                       = try(ipv.create_public_ip_address, false) # Secure default - no public IP
          public_ip_address_name                         = try(ipv.public_ip_address_name, null)
          public_ip_address_resource_id                  = try(ipv.public_ip_address_resource_id, null)
          public_ip_address_allocation                   = try(ipv.public_ip_address_allocation, "Static")
          public_ip_address_sku                          = try(ipv.public_ip_address_sku, "Standard")
          public_ip_address_availability_zone            = try(ipv.public_ip_address_availability_zone, "Zone-Redundant")
          public_ip_address_idle_timeout_in_minutes      = try(ipv.public_ip_address_idle_timeout_in_minutes, null)
          public_ip_address_ip_version                   = try(ipv.public_ip_address_ip_version, "IPv4")
          public_ip_address_sku_tier                     = try(ipv.public_ip_address_sku_tier, "Regional")
          public_ip_address_lock                         = try(ipv.public_ip_address_lock, null)
          public_ip_address_tags                         = try(ipv.public_ip_address_tags, null)
          public_ip_address_inherit_tags                 = try(ipv.public_ip_address_inherit_tags, true)
          public_ip_address_ddos_protection_mode         = try(ipv.public_ip_address_ddos_protection_mode, null)
          public_ip_address_ddos_protection_plan_id      = try(ipv.public_ip_address_ddos_protection_plan_id, null)
          public_ip_address_domain_name_label            = try(ipv.public_ip_address_domain_name_label, null)
          public_ip_address_domain_name_label_scope      = try(ipv.public_ip_address_domain_name_label_scope, null)
          public_ip_address_edge_zone                    = try(ipv.public_ip_address_edge_zone, null)
          public_ip_address_ip_tags                      = try(ipv.public_ip_address_ip_tags, null)
          public_ip_address_public_ip_prefix_resource_id = try(ipv.public_ip_address_public_ip_prefix_resource_id, null)
          public_ip_address_reverse_fqdn                 = try(ipv.public_ip_address_reverse_fqdn, null)
          public_ip_address_diagnostic_settings          = try(ipv.public_ip_address_diagnostic_settings, null)
          public_ip_address_role_assignments             = try(ipv.public_ip_address_role_assignments, null)
        }
      }

      # NIC-level settings
      accelerated_networking_enabled = try(v.accelerated_networking_enabled, true)
      dns_servers                    = try(v.dns_servers, null)
      edge_zone                      = try(v.edge_zone, null)
      internal_dns_name_label        = try(v.internal_dns_name_label, null)
      ip_forwarding_enabled          = try(v.ip_forwarding_enabled, false)
      lock                           = try(v.lock, null)
      network_security_group_resource_id = try(v.network_security_group_resource_id, null) != null ? v.network_security_group_resource_id : (
        try(v.nsg_key, null) != null ? module.nsg_foundation[v.nsg_key].resource_id : null
      )
      role_assignments    = try(v.role_assignments, null)
      diagnostic_settings = try(v.diagnostic_settings, null)
      inherit_tags        = try(v.inherit_tags, true)
      tags                = try(v.tags, null)
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
  }

  # Security - Secure defaults
  encryption_at_host_enabled = try(each.value.encryption_at_host_enabled, true) # Secure default
  secure_boot_enabled        = try(each.value.secure_boot_enabled, null)
  vtpm_enabled               = try(each.value.vtpm_enabled, null)

  # Account Credentials
  account_credentials = try(each.value.account_credentials, null)

  # Managed Identity - Prefer managed identity over credentials
  managed_identities = try(each.value.managed_identities, {
    system_assigned = true # Secure default - enable system-assigned MI
  })

  # Optional - Data Disks
  data_disk_managed_disks = try(each.value.data_disk_managed_disks, {})

  # Optional - Extensions
  extensions = try(each.value.extensions, {})

  # Optional - Run Commands
  run_commands = try(each.value.run_commands, {})

  # Optional - Boot Diagnostics
  boot_diagnostics                     = try(each.value.boot_diagnostics, false)
  boot_diagnostics_storage_account_uri = try(each.value.boot_diagnostics_storage_account_uri, null)

  # Optional - Priority (Regular or Spot)
  priority        = try(each.value.priority, "Regular")
  eviction_policy = try(each.value.eviction_policy, null)
  max_bid_price   = try(each.value.max_bid_price, null)

  # Optional - Patching
  patch_mode                                             = try(each.value.patch_mode, null)
  patch_assessment_mode                                  = try(each.value.patch_assessment_mode, null)
  bypass_platform_safety_checks_on_user_schedule_enabled = try(each.value.bypass_platform_safety_checks_on_user_schedule_enabled, null)
  hotpatching_enabled                                    = try(each.value.hotpatching_enabled, null)

  # Optional - Availability
  availability_set_resource_id           = try(each.value.availability_set_resource_id, null)
  capacity_reservation_group_resource_id = try(each.value.capacity_reservation_group_resource_id, null)
  dedicated_host_resource_id             = try(each.value.dedicated_host_resource_id, null)
  dedicated_host_group_resource_id       = try(each.value.dedicated_host_group_resource_id, null)
  proximity_placement_group_resource_id  = try(each.value.proximity_placement_group_resource_id, null)
  virtual_machine_scale_set_resource_id  = try(each.value.virtual_machine_scale_set_resource_id, null)
  platform_fault_domain                  = try(each.value.platform_fault_domain, null)

  # Optional - Shutdown Schedule
  shutdown_schedules = try(each.value.shutdown_schedules, {})

  # Optional - Backup
  azure_backup_configurations = try(each.value.azure_backup_configurations, {})

  # Optional - Resource Lock
  lock = try(each.value.lock, null)

  # Optional - Role Assignments
  role_assignments = try(each.value.role_assignments, {})

  # Optional - Diagnostic Settings
  diagnostic_settings = try(each.value.diagnostic_settings, {})

  # Optional - Timeouts
  timeouts = try(each.value.timeouts, null)

  # Tags
  tags = merge(local.tags, try(each.value.tags, {}))
}
