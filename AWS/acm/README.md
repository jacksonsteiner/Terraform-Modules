# ACM Certificate Module

Hardened ACM certificate module wrapping [`terraform-aws-modules/acm/aws`](https://registry.terraform.io/modules/terraform-aws-modules/acm/aws) ~> 5.0 with secure defaults.

## Features

- **DNS validation by default** - Preferred over email for full automation of certificate issuance and renewal
- **Certificate Transparency logging enabled** - CT logging is enabled by default for visibility and compliance
- **Automatic Route53 validation** - Validation DNS records are created and managed automatically when a `zone_id` is provided
- **Subject Alternative Names (SANs)** - Support for multiple domains on a single certificate
- **Multiple hosted zones** - Support for certificates spanning domains across different Route53 hosted zones via the `zones` parameter
- **Standard tagging** - Consistent `project` and `environment` tags applied to all certificates

## Usage

```hcl
module "certificates" {
  source = "../../AWS/acm"

  project_name = "myblog"
  environment  = "prod"
  region_short = "use1"

  certificates = {
    blog = {
      domain_name = "blog.example.com"
      zone_id     = "Z0123456789ABCDEF"

      subject_alternative_names = [
        "*.blog.example.com",
        "cdn.example.com",
      ]

      tags = {
        service = "blog"
      }
    }
  }
}

output "blog_cert_arn" {
  value = module.certificates.certificate_arns["blog"]
}
```

> **Note:** ACM certificates used with Amazon CloudFront **must** be requested in the `us-east-1` region regardless of where your other resources are deployed. Configure an aliased AWS provider targeting `us-east-1` for CloudFront certificates.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_name | Project name used for resource naming and tagging | `string` | - | yes |
| environment | Environment identifier (e.g., 'dev', 'staging', 'prod') | `string` | - | yes |
| region_short | Short region code used in naming (e.g., 'use1', 'usw2') | `string` | - | yes |
| certificates | Map of ACM certificates to create | `map(object({...}))` | `{}` | no |

### Certificate Object Fields

| Name | Description | Type | Default |
|------|-------------|------|---------|
| domain_name | Primary domain for the certificate | `string` | - (required) |
| subject_alternative_names | Additional domains for the certificate | `list(string)` | `[]` |
| validation_method | Validation method: DNS or EMAIL | `string` | `"DNS"` |
| zone_id | Route53 hosted zone ID for DNS validation | `string` | `""` |
| zones | Map of zone IDs for multi-domain certificates | `map(string)` | `{}` |
| create_route53_records | Auto-create Route53 validation records | `bool` | `true` |
| validate_certificate | Auto-validate the certificate | `bool` | `true` |
| wait_for_validation | Wait for validation to complete | `bool` | `true` |
| validation_timeout | Timeout for validation | `string` | `null` |
| certificate_transparency_logging_preference | Enable CT logging | `bool` | `true` |
| key_algorithm | Key algorithm (RSA_2048, EC_prime256v1, etc.) | `string` | `null` |
| validation_allow_overwrite_records | Allow overwriting validation records | `bool` | `true` |
| validation_option | Validation option configuration | `any` | `{}` |
| validation_record_fqdns | List of FQDNs for external validation | `list(string)` | `[]` |
| dns_ttl | TTL for DNS validation records | `number` | `60` |
| tags | Additional tags for the certificate | `map(string)` | `null` |

## Outputs

| Name | Description |
|------|-------------|
| certificates | Map of created ACM certificates with all attributes |
| certificate_arns | Map of ACM certificate ARNs |
| certificate_domain_validation_options | Map of domain validation options for certificates |
| certificate_statuses | Map of certificate statuses |
| validation_route53_record_fqdns | Map of Route53 validation record FQDNs |
