locals {
  suffix = join("-", compact([
    var.project_name, var.environment, var.location_short
  ]))

  names = {
    bastion = "bastion-${local.suffix}"
    pip     = "pip-${local.suffix}"
  }

  tags = {
    project     = var.project_name
    environment = var.environment
    location    = var.location
  }
}

module "bastions" {
  source  = "Azure/avm-res-network-bastionhost/azurerm"
  version = "~> 0.9"

  for_each = var.bastions

  # Required
  name      = coalesce(try(each.value.name, null), "${local.names.bastion}-${each.key}")
  location  = coalesce(try(each.value.location, null), var.location)
  parent_id = each.value.parent_id

  # Optional - SKU Configuration
  sku = coalesce(try(each.value.sku, null), "Basic")

  # Optional - Feature Flags (SKU-dependent)
  copy_paste_enabled        = try(each.value.copy_paste_enabled, true)
  file_copy_enabled         = try(each.value.file_copy_enabled, false)
  ip_connect_enabled        = try(each.value.ip_connect_enabled, false)
  kerberos_enabled          = try(each.value.kerberos_enabled, false)
  shareable_link_enabled    = try(each.value.shareable_link_enabled, false)
  tunneling_enabled         = try(each.value.tunneling_enabled, false)
  session_recording_enabled = try(each.value.session_recording_enabled, false)
  private_only_enabled      = try(each.value.private_only_enabled, false)

  # Optional - Scale and Availability
  scale_units = try(each.value.scale_units, 2)
  zones       = try(each.value.zones, coalesce(try(each.value.sku, null), "Basic") == "Developer" ? [] : ["1", "2", "3"])

  # Optional - Virtual Network (Developer SKU only)
  virtual_network_id = try(each.value.virtual_network_id, null)

  # Optional - Telemetry
  enable_telemetry = coalesce(try(each.value.enable_telemetry, null), false)

  # Optional - Resource Lock
  lock = try(each.value.lock, null)

  # Optional - Role Assignments
  role_assignments = try(each.value.role_assignments, {})

  # Optional - Diagnostic Settings
  diagnostic_settings = try(each.value.diagnostic_settings, {})

  # IP Configuration (null for Developer SKU, required for all other SKUs)
  ip_configuration = coalesce(try(each.value.sku, null), "Basic") == "Developer" ? null : {
    name                             = coalesce(try(each.value.ip_configuration.name, null), "ipconfig")
    subnet_id                        = each.value.subnet_id
    create_public_ip                 = coalesce(try(each.value.ip_configuration.create_public_ip, null), true)
    public_ip_address_id             = try(each.value.ip_configuration.public_ip_address_id, null)
    public_ip_address_name           = coalesce(try(each.value.ip_configuration.public_ip_address_name, null), "${local.names.pip}-${each.key}")
    public_ip_tags                   = try(each.value.ip_configuration.public_ip_tags, null)
    public_ip_merge_with_module_tags = coalesce(try(each.value.ip_configuration.public_ip_merge_with_module_tags, null), true)
  }

  # Tags
  tags = merge(local.tags, try(each.value.tags, {}))
}
