# AWS CloudFront Distribution Module

Terraform module for creating hardened Amazon CloudFront distributions. Wraps the community module [`terraform-aws-modules/cloudfront/aws`](https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws) version ~> 4.0 with secure-by-default settings.

## Features

- **HTTPS Redirect** - All HTTP requests are automatically redirected to HTTPS
- **TLS 1.2+ Minimum** - Enforces `TLSv1.2_2021` as the minimum protocol version
- **SNI-Only** - Uses Server Name Indication to reduce costs and improve security
- **Origin Access Control (OAC)** - Default S3 OAC configured (replaces legacy OAI)
- **HTTP/2 and HTTP/3** - Latest HTTP versions enabled by default for performance
- **WAF Integration** - Optional AWS WAF WebACL attachment via `web_acl_id`
- **Response Headers Policies** - Support for security headers (CSP, HSTS, etc.)
- **CloudFront Functions** - Support for edge compute at CloudFront edge locations
- **Monitoring** - Optional real-time metrics subscription
- **Standard Naming** - Resources follow `{project}-{environment}-{region_short}-{key}` convention
- **Cost-Efficient Default** - `PriceClass_100` limits edge locations to lowest-cost regions

## Usage

### Static Site with S3 Origin

```hcl
module "cloudfront" {
  source = "path/to/AWS/cloudfront"

  project_name = "myapp"
  environment  = "prod"
  region_short = "use1"

  distributions = {
    website = {
      aliases             = ["www.example.com"]
      default_root_object = "index.html"

      origin = {
        s3 = {
          domain_name           = "my-bucket.s3.us-east-1.amazonaws.com"
          origin_access_control = "s3"
        }
      }

      default_cache_behavior = {
        target_origin_id       = "s3"
        cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
        use_forwarded_values   = false
      }

      viewer_certificate = {
        acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc-123"
      }

      custom_error_response = [
        {
          error_code         = 404
          response_code      = 200
          response_page_path = "/index.html"
        }
      ]
    }
  }
}
```

## Security Defaults

| Setting | Default Value | Description |
|---|---|---|
| `viewer_protocol_policy` | `redirect-to-https` | Forces HTTPS for all viewer requests |
| `minimum_protocol_version` | `TLSv1.2_2021` | Minimum TLS version for HTTPS connections |
| `ssl_support_method` | `sni-only` | SNI-based certificate selection |
| `http_version` | `http2and3` | Latest HTTP protocol versions enabled |
| `origin_access_control` | S3 OAC with SigV4 | Secure S3 origin access (replaces legacy OAI) |
| `compress` | `true` | Automatic compression for supported content types |

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |

## Inputs

| Name | Type | Required | Description |
|---|---|---|---|
| `project_name` | `string` | Yes | Project name used for resource naming and tagging |
| `environment` | `string` | Yes | Environment identifier (e.g., dev, staging, prod) |
| `region_short` | `string` | Yes | Short region code used in naming (e.g., use1, usw2) |
| `distributions` | `map(object)` | Yes | Map of CloudFront distribution configurations |

See `variables.tf` for the full `distributions` object schema and all configurable fields.

## Outputs

| Name | Description |
|---|---|
| `distributions` | Map of created CloudFront distributions with all attributes |
| `distribution_ids` | Map of CloudFront distribution IDs |
| `distribution_arns` | Map of CloudFront distribution ARNs |
| `distribution_domain_names` | Map of CloudFront distribution domain names |
| `distribution_hosted_zone_ids` | Map of distribution hosted zone IDs (for Route53 alias records) |
| `origin_access_controls` | Map of origin access control IDs |
