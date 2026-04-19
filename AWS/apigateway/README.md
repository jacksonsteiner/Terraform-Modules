# AWS API Gateway v2 Module

Hardened Terraform module for AWS API Gateway v2 (HTTP and WebSocket APIs), wrapping the community module [`terraform-aws-modules/apigateway-v2/aws`](https://registry.terraform.io/modules/terraform-aws-modules/apigateway-v2/aws/latest) version ~> 5.0.

## Features

- **Default endpoint disabled** - The default `execute-api` endpoint is disabled by default, forcing usage through custom domains for improved security and control.
- **Access logging support** - Built-in stage access logging configuration for audit trails and compliance.
- **Mutual TLS authentication** - Support for mTLS to verify client certificates.
- **Throttling defaults** - Stage default route settings with configurable burst and rate throttling limits.
- **Standard naming convention** - Resources follow `{project}-{environment}-{region_short}-{key}` naming.
- **Authorizer support** - JWT, Lambda, and IAM authorizers.
- **Custom domain integration** - Route53 record creation and ACM certificate support.
- **VPC Link support** - Private integrations with backend services in VPCs.

## Usage

```hcl
module "api_gateway" {
  source = "../../AWS/apigateway"

  project_name = "blog"
  environment  = "prod"
  region_short = "use1"

  apis = {
    main = {
      description   = "Blog API"
      protocol_type = "HTTP"

      # Security - default endpoint is already disabled (hardened default)
      disable_execute_api_endpoint = true

      cors_configuration = {
        allow_origins = ["https://blog.example.com"]
        allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
        allow_headers = ["Content-Type", "Authorization"]
        max_age       = 3600
      }

      routes = {
        "GET /posts" = {
          integration = {
            uri                    = "arn:aws:lambda:us-east-1:123456789012:function:blog-get-posts"
            type                   = "AWS_PROXY"
            payload_format_version = "2.0"
          }
        }
        "POST /posts" = {
          authorization_type = "JWT"
          authorizer_key     = "cognito"
          integration = {
            uri                    = "arn:aws:lambda:us-east-1:123456789012:function:blog-create-post"
            type                   = "AWS_PROXY"
            payload_format_version = "2.0"
          }
        }
      }

      authorizers = {
        cognito = {
          authorizer_type  = "JWT"
          identity_sources = ["$request.header.Authorization"]
          jwt_configuration = {
            issuer   = "https://cognito-idp.us-east-1.amazonaws.com/us-east-1_EXAMPLE"
            audience = ["blog-client-id"]
          }
        }
      }

      # Access logging (HARDENED)
      stage_access_log_settings = {
        create_log_group            = true
        log_group_retention_in_days = 90
        format = jsonencode({
          requestId      = "$context.requestId"
          ip             = "$context.identity.sourceIp"
          requestTime    = "$context.requestTime"
          httpMethod     = "$context.httpMethod"
          routeKey       = "$context.routeKey"
          status         = "$context.status"
          protocol       = "$context.protocol"
          responseLength = "$context.responseLength"
          errorMessage   = "$context.error.message"
        })
      }

      # Throttling
      stage_default_route_settings = {
        detailed_metrics_enabled = true
        throttling_burst_limit   = 100
        throttling_rate_limit    = 50
      }

      # Custom domain
      create_domain_name          = true
      domain_name                 = "api.blog.example.com"
      domain_name_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abc-123"

      tags = {
        team = "backend"
      }
    }
  }
}
```

## Security Defaults

| Setting | Default | Description |
|---|---|---|
| `disable_execute_api_endpoint` | `true` | Disables the default execute-api endpoint, forcing traffic through custom domains |
| `mutual_tls_authentication` | `{}` | Mutual TLS disabled by default; provide truststore URI to enable |
| `stage_access_log_settings` | `{}` | Access logging disabled by default; strongly recommended for production |
| `stage_default_route_settings` | `{}` | No throttling by default; recommended to set burst and rate limits |

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `project_name` | Project name used for resource naming and tagging | `string` | n/a | yes |
| `environment` | Environment identifier (e.g., 'dev', 'staging', 'prod') | `string` | n/a | yes |
| `region_short` | Short region code used in naming (e.g., 'use1', 'usw2') | `string` | n/a | yes |
| `apis` | Map of API Gateway v2 configurations to create | `map(object({...}))` | `{}` | no |

See `variables.tf` for the full `apis` object schema including all nested fields.

## Outputs

| Name | Description |
|---|---|
| `apis` | Map of created API Gateways with all attributes |
| `api_ids` | Map of API Gateway IDs |
| `api_endpoints` | Map of API Gateway endpoints |
| `api_execution_arns` | Map of API Gateway execution ARNs |
| `stage_ids` | Map of API Gateway stage IDs |
| `domain_names` | Map of API Gateway custom domain names |
