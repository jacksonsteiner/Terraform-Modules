locals {
  suffix = join("-", compact([
    var.project_name, var.environment, var.location_short
  ]))

  tags = {
    project     = var.project_name
    environment = var.environment
    location    = var.location
  }
}

module "resource_groups" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "~> 0.2"

  for_each = var.resource_groups

  # Required
  name     = coalesce(try(each.value.name, null), "rg-${local.suffix}-${each.key}")
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
