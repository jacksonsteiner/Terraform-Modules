locals {
  suffix = join("-", compact([var.project_name, var.environment, var.region_short]))

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 5.5.0"

  for_each = var.tables

  name      = coalesce(try(each.value.name, null), "${local.suffix}-${each.key}")
  hash_key  = each.value.hash_key
  range_key = try(each.value.range_key, null)

  attributes = each.value.attributes

  # Billing
  billing_mode   = coalesce(try(each.value.billing_mode, null), "PAY_PER_REQUEST")
  read_capacity  = try(each.value.read_capacity, null)
  write_capacity = try(each.value.write_capacity, null)
  table_class    = try(each.value.table_class, null)

  # Security - Encryption (HARDENED: enabled by default)
  server_side_encryption_enabled     = coalesce(try(each.value.server_side_encryption_enabled, null), true)
  server_side_encryption_kms_key_arn = try(each.value.server_side_encryption_kms_key_arn, null)

  # Security - Point-in-Time Recovery (HARDENED: enabled by default)
  point_in_time_recovery_enabled = coalesce(try(each.value.point_in_time_recovery_enabled, null), true)

  # Security - Deletion Protection (HARDENED: enabled by default)
  deletion_protection_enabled = coalesce(try(each.value.deletion_protection_enabled, null), true)

  # Streams
  stream_enabled   = coalesce(try(each.value.stream_enabled, null), false)
  stream_view_type = try(each.value.stream_view_type, null)

  # TTL
  ttl_enabled        = coalesce(try(each.value.ttl_enabled, null), false)
  ttl_attribute_name = try(each.value.ttl_attribute_name, "")

  # Indexes
  global_secondary_indexes = try(each.value.global_secondary_indexes, [])
  local_secondary_indexes  = try(each.value.local_secondary_indexes, [])

  # Replication
  replica_regions = try(each.value.replica_regions, [])

  # Autoscaling
  autoscaling_enabled  = coalesce(try(each.value.autoscaling_enabled, null), false)
  autoscaling_defaults = try(each.value.autoscaling_defaults, null)
  autoscaling_read     = try(each.value.autoscaling_read, {})
  autoscaling_write    = try(each.value.autoscaling_write, {})
  autoscaling_indexes  = try(each.value.autoscaling_indexes, {})

  # Timeouts
  timeouts = try(each.value.timeouts, null)

  # Resource Policy
  resource_policy = try(each.value.resource_policy, null)

  tags = merge(local.tags, try(each.value.tags, {}))
}
