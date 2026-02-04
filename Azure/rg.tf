module "rg_foundation" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.2"

  for_each = var.rg_foundation

  # Required
  name     = coalesce(try(each.value.name, null), local.names.rg)
  location = coalesce(try(each.value.location, null), var.location)

  # Optional - Telemetry
  enable_telemetry = coalesce(try(each.value.enable_telemetry, null), false)

  # Optional - Resource Lock
  lock = try(each.value.lock, null)

  # Optional - Role Assignments
  role_assignments = try(each.value.role_assignments, {})

  # Tags
  tags = merge(local.tags, try(each.value.tags, {}))
}
