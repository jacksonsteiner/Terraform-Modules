locals {
  suffix = join("-", compact([var.project_name, var.environment, var.region_short]))

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = ">= 5.10.0"

  for_each = var.s3_buckets

  bucket        = try(each.value.bucket, null) != null ? each.value.bucket : "${local.suffix}-${each.key}"
  bucket_prefix = try(each.value.bucket_prefix, null)
  force_destroy = coalesce(try(each.value.force_destroy, null), false)

  acceleration_status = try(each.value.acceleration_status, null)
  request_payer       = try(each.value.request_payer, null)

  # Security - Public Access Block (all blocked by default)
  block_public_acls       = coalesce(try(each.value.block_public_acls, null), true)
  block_public_policy     = coalesce(try(each.value.block_public_policy, null), true)
  ignore_public_acls      = coalesce(try(each.value.ignore_public_acls, null), true)
  restrict_public_buckets = coalesce(try(each.value.restrict_public_buckets, null), true)

  # Security - Transport Policies (hardened by default)
  attach_deny_insecure_transport_policy    = coalesce(try(each.value.attach_deny_insecure_transport_policy, null), true)
  attach_require_latest_tls_policy         = coalesce(try(each.value.attach_require_latest_tls_policy, null), true)
  attach_deny_unencrypted_object_uploads   = coalesce(try(each.value.attach_deny_unencrypted_object_uploads, null), true)
  attach_deny_incorrect_encryption_headers = coalesce(try(each.value.attach_deny_incorrect_encryption_headers, null), false)
  attach_deny_incorrect_kms_key_sse        = coalesce(try(each.value.attach_deny_incorrect_kms_key_sse, null), false)
  allowed_kms_key_arn                      = try(each.value.allowed_kms_key_arn, null)

  # Security - Bucket Policy
  attach_policy = coalesce(try(each.value.attach_policy, null), false)
  policy        = try(each.value.policy, null)

  # Security - Log Delivery Policies
  attach_elb_log_delivery_policy    = coalesce(try(each.value.attach_elb_log_delivery_policy, null), false)
  attach_lb_log_delivery_policy     = coalesce(try(each.value.attach_lb_log_delivery_policy, null), false)
  attach_access_log_delivery_policy = coalesce(try(each.value.attach_access_log_delivery_policy, null), false)

  # Security - Object Ownership (BucketOwnerEnforced disables ACLs)
  control_object_ownership = coalesce(try(each.value.control_object_ownership, null), true)
  object_ownership         = coalesce(try(each.value.object_ownership, null), "BucketOwnerEnforced")

  # Encryption (AES256 by default)
  server_side_encryption_configuration = try(each.value.server_side_encryption_configuration, {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  })

  # Versioning (enabled by default for data protection)
  versioning = try(each.value.versioning, { enabled = true })

  # Features
  website                   = try(each.value.website, {})
  cors_rule                 = try(each.value.cors_rule, [])
  logging                   = try(each.value.logging, {})
  lifecycle_rule            = try(each.value.lifecycle_rule, [])
  replication_configuration = try(each.value.replication_configuration, {})
  object_lock_enabled       = coalesce(try(each.value.object_lock_enabled, null), false)
  object_lock_configuration = try(each.value.object_lock_configuration, {})
  intelligent_tiering       = try(each.value.intelligent_tiering, {})
  metric_configuration      = try(each.value.metric_configuration, [])
  acl                       = try(each.value.acl, null)
  grant                     = try(each.value.grant, [])
  expected_bucket_owner     = try(each.value.expected_bucket_owner, null)

  tags = merge(local.tags, try(each.value.tags, {}))
}
