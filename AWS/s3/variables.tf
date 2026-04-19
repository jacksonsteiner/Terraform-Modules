variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "region_short" {
  description = "Short region identifier (e.g., use1, usw2, euw1)"
  type        = string
}

variable "s3_buckets" {
  description = "Map of S3 bucket configurations with hardened security defaults"
  type = map(object({
    # Naming
    bucket        = optional(string)
    bucket_prefix = optional(string)
    force_destroy = optional(bool, false)

    # General
    acceleration_status = optional(string)
    request_payer       = optional(string)
    tags                = optional(map(string))

    # Security - Public Access Block (all blocked by default)
    block_public_acls       = optional(bool, true)
    block_public_policy     = optional(bool, true)
    ignore_public_acls      = optional(bool, true)
    restrict_public_buckets = optional(bool, true)

    # Security - Transport Policies (hardened by default)
    attach_deny_insecure_transport_policy    = optional(bool, true)
    attach_require_latest_tls_policy         = optional(bool, true)
    attach_deny_unencrypted_object_uploads   = optional(bool, true)
    attach_deny_incorrect_encryption_headers = optional(bool, false)
    attach_deny_incorrect_kms_key_sse        = optional(bool, false)
    allowed_kms_key_arn                      = optional(string)

    # Security - Bucket Policy
    attach_policy = optional(bool, false)
    policy        = optional(string)

    # Security - Log Delivery Policies
    attach_elb_log_delivery_policy    = optional(bool, false)
    attach_lb_log_delivery_policy     = optional(bool, false)
    attach_access_log_delivery_policy = optional(bool, false)

    # Security - Object Ownership (BucketOwnerEnforced disables ACLs)
    control_object_ownership = optional(bool, true)
    object_ownership         = optional(string, "BucketOwnerEnforced")

    # Encryption (AES256 by default)
    server_side_encryption_configuration = optional(any, {
      rule = {
        apply_server_side_encryption_by_default = {
          sse_algorithm = "AES256"
        }
      }
    })

    # Versioning (enabled by default for data protection)
    versioning = optional(map(string), { enabled = true })

    # Features
    website                   = optional(any, {})
    cors_rule                 = optional(any, [])
    logging                   = optional(any, {})
    lifecycle_rule            = optional(any, [])
    replication_configuration = optional(any, {})
    object_lock_enabled       = optional(bool, false)
    object_lock_configuration = optional(any, {})
    intelligent_tiering       = optional(any, {})
    metric_configuration      = optional(any, [])
    acl                       = optional(string)
    grant                     = optional(any, [])
    expected_bucket_owner     = optional(string)
  }))
  default = {}
}
