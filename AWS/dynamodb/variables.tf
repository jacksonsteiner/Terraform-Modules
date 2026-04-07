variable "project_name" {
  type        = string
  description = "Project name used for resource naming and tagging"
}

variable "environment" {
  type        = string
  description = "Environment identifier (e.g., 'dev', 'staging', 'prod')"
}

variable "region_short" {
  type        = string
  description = "Short region code used in naming (e.g., 'use1', 'usw2')"
}

variable "tables" {
  description = "Map of DynamoDB table configurations to create"
  type = map(object({
    # Required
    hash_key   = string
    attributes = list(object({ name = string, type = string }))

    # Optional - Core
    name           = optional(string)
    range_key      = optional(string)
    billing_mode   = optional(string, "PAY_PER_REQUEST")
    read_capacity  = optional(number)
    write_capacity = optional(number)
    table_class    = optional(string)
    tags           = optional(map(string))

    # Optional - Security (HARDENED defaults)
    server_side_encryption_enabled     = optional(bool, true)
    server_side_encryption_kms_key_arn = optional(string)
    point_in_time_recovery_enabled     = optional(bool, true)
    deletion_protection_enabled        = optional(bool, true)

    # Optional - Streams
    stream_enabled   = optional(bool, false)
    stream_view_type = optional(string)

    # Optional - TTL
    ttl_enabled        = optional(bool, false)
    ttl_attribute_name = optional(string, "")

    # Optional - Indexes
    global_secondary_indexes = optional(any, [])
    local_secondary_indexes  = optional(any, [])

    # Optional - Replication
    replica_regions = optional(any, [])

    # Optional - Autoscaling
    autoscaling_enabled  = optional(bool, false)
    autoscaling_defaults = optional(map(string))
    autoscaling_read     = optional(map(string), {})
    autoscaling_write    = optional(map(string), {})
    autoscaling_indexes  = optional(map(map(string)), {})

    # Optional - Other
    timeouts        = optional(map(string))
    resource_policy = optional(string)
  }))
}
