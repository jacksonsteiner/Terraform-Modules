# AWS S3 Bucket Module

Hardened S3 bucket module wrapping [`terraform-aws-modules/s3-bucket/aws`](https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest) version ~> 4.0 with security-first defaults.

## Features

- **Security Hardened by Default** -- All public access blocked, encryption enabled, insecure transport denied
- **Deny Non-SSL Traffic** -- `attach_deny_insecure_transport_policy` enabled by default
- **Require TLS 1.2+** -- `attach_require_latest_tls_policy` enabled by default
- **Deny Unencrypted Uploads** -- `attach_deny_unencrypted_object_uploads` enabled by default
- **ACLs Disabled** -- `BucketOwnerEnforced` object ownership by default
- **AES256 Encryption** -- Server-side encryption with Amazon S3 managed keys by default
- **Versioning Enabled** -- Protects against accidental deletion and overwrites
- **Standard Naming** -- Automatic bucket naming: `{project}-{environment}-{region_short}-{key}`
- **Full Feature Support** -- Website hosting, CORS, lifecycle rules, replication, intelligent tiering, object lock, and more

## Usage

```hcl
module "s3" {
  source = "path/to/modules/AWS/s3"

  project_name = "myapp"
  environment  = "prod"
  region_short = "use1"

  s3_buckets = {
    blog = {}

    logs = {
      attach_elb_log_delivery_policy = true
      lifecycle_rule = [
        {
          id      = "expire-old-logs"
          enabled = true
          expiration = {
            days = 90
          }
        }
      ]
    }

    static-site = {
      website = {
        index_document = "index.html"
        error_document = "error.html"
      }
      cors_rule = [
        {
          allowed_methods = ["GET"]
          allowed_origins = ["https://example.com"]
          allowed_headers = ["*"]
          max_age_seconds = 3600
        }
      ]
    }
  }
}
```

The `blog` bucket above will be created as `myapp-prod-use1-blog` with all hardened defaults -- no extra configuration needed.

## Security Defaults

| Setting | Default | Description |
|---------|---------|-------------|
| `block_public_acls` | `true` | Block public ACLs |
| `block_public_policy` | `true` | Block public bucket policies |
| `ignore_public_acls` | `true` | Ignore public ACLs |
| `restrict_public_buckets` | `true` | Restrict public bucket access |
| `attach_deny_insecure_transport_policy` | `true` | Deny non-SSL requests |
| `attach_require_latest_tls_policy` | `true` | Require TLS 1.2+ |
| `attach_deny_unencrypted_object_uploads` | `true` | Deny unencrypted uploads |
| `control_object_ownership` | `true` | Control object ownership |
| `object_ownership` | `BucketOwnerEnforced` | Disable ACLs |
| `server_side_encryption_configuration` | AES256 | SSE-S3 encryption |
| `versioning` | `{ enabled = true }` | Bucket versioning |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |
| terraform-aws-modules/s3-bucket/aws | ~> 4.0 |

## Inputs

| Name | Type | Description |
|------|------|-------------|
| `project_name` | `string` | The name of the project |
| `environment` | `string` | The environment name (e.g., dev, staging, prod) |
| `region_short` | `string` | Short region identifier (e.g., use1, usw2, euw1) |
| `s3_buckets` | `map(object({...}))` | Map of S3 bucket configurations (see `variables.tf` for full schema) |

## Outputs

| Name | Description |
|------|-------------|
| `s3_buckets` | Map of created S3 buckets with all attributes |
| `s3_bucket_ids` | Map of S3 bucket IDs |
| `s3_bucket_arns` | Map of S3 bucket ARNs |
| `s3_bucket_domain_names` | Map of S3 bucket domain names |
| `s3_bucket_regional_domain_names` | Map of S3 bucket regional domain names |
