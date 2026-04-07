
---

# Terraform Standards with AWS Community Modules

This document defines Terraform standards, community module usage patterns, and security considerations for reusable AWS infrastructure modules.

---

## Claude Instructions

### Periodic Module Update Checks

When working in this repository, **periodically check for updates** to the upstream AWS community modules:

1. **Check upstream sources** - Visit the GitHub repositories for each community module used in this project to identify new versions, changed variables, or deprecated features
2. **Compare with local modules** - Review local module implementations against the latest community `variables.tf` and `main.tf` files
3. **Identify gaps** - Note any new variables, security features, or best practices that should be incorporated

### Changelog Requirements

When updating local modules based on community module changes, **always update the CHANGELOG.md**:

```markdown
## [YYYY-MM-DD] - Module Update

### Changed
- Updated `module-name` to align with community module version x.x.x
- Added new variable `variable_name` for [purpose]

### Added
- New security feature: [description]
- Support for [new capability]

### Deprecated
- Variable `old_var` replaced by `new_var`

### Breaking Changes
- [Any breaking changes that require consumer updates]
```

**Update workflow:**
1. Fetch latest community module version and review changes
2. Update local module code to incorporate changes
3. Update CHANGELOG.md with all modifications
4. Run `terraform fmt` and `terraform validate`
5. Test changes before committing

### Cloud Security Best Practices

When creating or updating modules, **always follow secure-by-default principles**:

**Secure Default Values**

Always set variable defaults to the most secure option. Consumers can explicitly opt-in to less secure configurations when needed.

| Setting | Secure Default | Insecure (avoid as default) |
|---------|---------------|----------------------------|
| S3 public access block | All `true` | Any `false` |
| S3 encryption | SSE-S3 (`AES256`) enabled | No encryption |
| S3 versioning | `Enabled` | `Disabled` |
| SSL/TLS minimum version | `TLSv1.2_2021` | `TLSv1`, `SSLv3` |
| CloudFront viewer protocol | `redirect-to-https` | `allow-all` |
| DynamoDB encryption | `true` (AWS managed) | `false` |
| DynamoDB PITR | `true` | `false` |
| DynamoDB deletion protection | `true` | `false`/`null` |
| Lambda tracing | `Active` | `PassThrough` |
| API Gateway default endpoint | `true` (disabled) | `false` |
| API Gateway access logging | Enabled | Disabled |
| Deny insecure transport | `true` | `false` |

**Example - Secure Variable Defaults:**
```hcl
variable "block_public_acls" {
  description = "Whether to block public ACLs for the S3 bucket."
  type        = bool
  default     = true  # Secure default - block all public ACLs
}

variable "server_side_encryption_configuration" {
  description = "S3 server-side encryption configuration. Defaults to AES256."
  type        = any
  default = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}
```

**Security Principles for Module Development:**

1. **Block public access** - S3 buckets must block all public access by default
2. **Encrypt everything** - Enable encryption at rest (SSE) and in transit (TLS 1.2+) by default
3. **Deny insecure transport** - Attach policies denying non-HTTPS requests to S3 buckets
4. **Require latest TLS** - Enforce TLS 1.2+ on all HTTPS endpoints
5. **Enable versioning** - S3 bucket versioning enabled by default for data protection
6. **Point-in-time recovery** - DynamoDB PITR enabled by default
7. **Deletion protection** - Enable deletion protection on stateful resources
8. **Least privilege** - IAM roles with minimal required permissions
9. **VPC isolation** - Lambda functions should support VPC deployment
10. **Access logging** - Enable access logs for CloudFront, API Gateway, and S3
11. **Origin access control** - Use OAC (not OAI) for CloudFront-to-S3 access
12. **HTTPS only** - CloudFront should redirect HTTP to HTTPS

**When Reviewing or Creating Modules, Ask:**

- Is public access blocked by default?
- Is encryption enabled by default?
- Are secure protocol versions enforced (TLS 1.2+)?
- Is access logging configurable?
- Are IAM permissions following least privilege?
- Is deletion protection enabled for stateful resources?
- Are insecure transport policies attached?
- Do defaults align with AWS CIS Benchmark controls?

### Cost-Conscious Infrastructure

Balance security requirements with cost efficiency.

**Cost-Aware Default Values:**

| Resource | Cost-Efficient Default | Expensive (justify if needed) |
|----------|----------------------|------------------------------|
| DynamoDB billing | `PAY_PER_REQUEST` | `PROVISIONED` (only for predictable workloads) |
| S3 storage class | Standard | Glacier (for archival only) |
| CloudFront price class | `PriceClass_100` | `PriceClass_All` (global distribution) |
| Lambda memory | 128 MB | Higher values (only if needed) |
| Lambda timeout | 3 seconds | Higher values (only if needed) |
| API Gateway | HTTP API | REST API (only if features needed) |
| Log retention | 30 days | 365+ days (only if compliance requires) |

---

## AWS Community Module Sources

| Resource Type | GitHub Repository | Variables Reference |
|---------------|-------------------|---------------------|
| S3 Bucket | [terraform-aws-s3-bucket](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket) | [variables.tf](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/blob/master/variables.tf) |
| CloudFront | [terraform-aws-cloudfront](https://github.com/terraform-aws-modules/terraform-aws-cloudfront) | [variables.tf](https://github.com/terraform-aws-modules/terraform-aws-cloudfront/blob/master/variables.tf) |
| ACM | [terraform-aws-acm](https://github.com/terraform-aws-modules/terraform-aws-acm) | [variables.tf](https://github.com/terraform-aws-modules/terraform-aws-acm/blob/master/variables.tf) |
| Lambda | [terraform-aws-lambda](https://github.com/terraform-aws-modules/terraform-aws-lambda) | [variables.tf](https://github.com/terraform-aws-modules/terraform-aws-lambda/blob/master/variables.tf) |
| DynamoDB | [terraform-aws-dynamodb-table](https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table) | [variables.tf](https://github.com/terraform-aws-modules/terraform-aws-dynamodb-table/blob/master/variables.tf) |
| API Gateway v2 | [terraform-aws-apigateway-v2](https://github.com/terraform-aws-modules/terraform-aws-apigateway-v2) | [variables.tf](https://github.com/terraform-aws-modules/terraform-aws-apigateway-v2/blob/master/variables.tf) |

### Version Pinning Strategy

```hcl
# Use pessimistic constraint to allow patch updates
version = "~> 4.0"  # Allows 4.x but not 5.0

# For production stability, pin to exact version
version = "4.2.2"   # Exact version, no automatic updates
```

### Module Usage Rules

1. **Search for a community module first** before writing raw `aws_*` resources
2. **Always pin module versions** using `version = "~> x.x"` constraints
3. **Check module inputs** at the GitHub repository for required and optional variables
4. **Use module outputs** to reference resource attributes rather than data sources
5. **Expose all security-relevant variables** to allow consumers to configure security settings

---

## General Terraform Best Practices

- Use `terraform fmt` before committing
- Run `terraform validate` to check syntax
- Store state remotely with state locking enabled (S3 + DynamoDB)
- Keep provider versions pinned
- Enable deletion protection on stateful resources (DynamoDB, S3)
- Store secrets in AWS Secrets Manager or SSM Parameter Store, never in code or tfvars
- Use IAM roles with least-privilege policies

---

## Security Considerations with AWS Community Modules

### Network Security

**VPC Configuration for Lambda**
```hcl
module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = var.security_group_ids
  attach_network_policy  = true
}
```

### Data Protection

**S3 Bucket Security**
```hcl
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  # Block all public access
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Enable encryption
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # Enable versioning
  versioning = {
    enabled = true
  }

  # Deny insecure transport
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true
}
```

**DynamoDB Encryption and Recovery**
```hcl
module "dynamodb_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 4.0"

  server_side_encryption_enabled = true
  point_in_time_recovery_enabled = true
  deletion_protection_enabled    = true
}
```

### Content Delivery Security

**CloudFront with HTTPS and OAC**
```hcl
module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 4.0"

  viewer_certificate = {
    acm_certificate_arn      = var.certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  default_cache_behavior = {
    viewer_protocol_policy = "redirect-to-https"
  }

  origin_access_control = {
    s3 = {
      description      = "OAC for S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }
}
```

### Security Checklist for AWS Modules

| Security Control | Implementation |
|-----------------|----------------|
| S3 Public Access | Block all public access via `block_public_*` variables |
| Encryption at Rest | SSE-S3 (AES256) or SSE-KMS for S3, DynamoDB encryption |
| Encryption in Transit | Deny insecure transport policy, TLS 1.2+ |
| Access Logging | S3 access logs, CloudFront logs, API Gateway access logs |
| Versioning | S3 versioning enabled for data recovery |
| Deletion Protection | DynamoDB deletion protection, S3 versioning |
| PITR | DynamoDB point-in-time recovery enabled |
| Origin Access | CloudFront OAC (not OAI) for S3 origins |
| HTTPS Only | CloudFront redirect-to-https, deny insecure transport |
| IAM Least Privilege | Lambda execution roles with minimum permissions |
| VPC Isolation | Lambda VPC configuration for private resources |

### Secrets Management

- **Never** store secrets in Terraform code or tfvars files
- Use AWS Secrets Manager or SSM Parameter Store for secrets
- Use Terraform data sources to read secrets
- Use IAM roles for service-to-service authentication

```hcl
data "aws_secretsmanager_secret_version" "example" {
  secret_id = var.secret_id
}
```
