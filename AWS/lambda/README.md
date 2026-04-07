# AWS Lambda Function Module

Hardened Terraform module for deploying AWS Lambda functions. Wraps the community module [`terraform-aws-modules/lambda/aws`](https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest) version ~> 7.0 with security-first defaults.

## Features

- **X-Ray Tracing** - Active tracing enabled by default for observability
- **VPC Support** - Automatic network policy attachment when VPC is configured
- **Dead Letter Queues** - Automatic DLQ policy attachment when a target ARN is provided
- **IAM Policies** - Flexible policy attachment via JSON, ARN, or inline statements
- **KMS Encryption** - Support for encrypting environment variables and CloudWatch Logs
- **Code Signing** - Optional code signing configuration for deployment integrity
- **Function URLs** - AWS_IAM authorization by default (no unauthenticated access)
- **ARM64 Architecture** - Cost-efficient Graviton processors by default
- **CloudWatch Logs** - 30-day retention by default
- **Event Source Mapping** - Support for SQS, Kinesis, DynamoDB Streams, and more
- **Layers** - Support for Lambda layers
- **Standard Naming** - Consistent `{project}-{environment}-{region_short}-{key}` convention

## Usage

```hcl
module "lambda" {
  source = "path/to/AWS/lambda"

  project_name = "blog"
  environment  = "prod"
  region_short = "use1"

  functions = {
    api_handler = {
      description = "Blog API request handler"
      handler     = "main.handler"
      runtime     = "nodejs20.x"
      memory_size = 256
      timeout     = 30

      source_path = "${path.module}/src/api"

      environment_variables = {
        TABLE_NAME = "blog-posts"
        LOG_LEVEL  = "info"
      }

      attach_policy_json = true
      policy_json = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect   = "Allow"
            Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query"]
            Resource = "arn:aws:dynamodb:us-east-1:123456789012:table/blog-posts"
          }
        ]
      })

      allowed_triggers = {
        api_gateway = {
          service    = "apigateway"
          source_arn = "arn:aws:execute-api:us-east-1:123456789012:abc123/*"
        }
      }
    }

    thumbnail_generator = {
      description = "Generate thumbnails from uploaded images"
      handler     = "resize.handler"
      runtime     = "python3.12"
      memory_size = 512
      timeout     = 60

      source_path = "${path.module}/src/thumbnails"

      dead_letter_target_arn = "arn:aws:sqs:us-east-1:123456789012:thumbnail-dlq"

      environment_variables = {
        BUCKET_NAME = "blog-images"
      }
    }
  }
}
```

## Security Defaults

| Setting | Default | Rationale |
|---|---|---|
| `tracing_mode` | `"Active"` | X-Ray tracing enabled for observability and debugging |
| `attach_tracing_policy` | `true` | IAM policy for X-Ray automatically attached |
| `authorization_type` | `"AWS_IAM"` | Function URLs require IAM authentication (no public access) |
| `architectures` | `["arm64"]` | Graviton processors for better price-performance |
| `cloudwatch_logs_retention_in_days` | `30` | Logs retained for 30 days (avoid unbounded growth) |
| `attach_cloudwatch_logs_policy` | `true` | CloudWatch Logs policy automatically attached |
| `attach_network_policy` | Auto | Automatically set to `true` when `vpc_subnet_ids` is provided |
| `attach_dead_letter_policy` | Auto | Automatically set to `true` when `dead_letter_target_arn` is provided |

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Required |
|---|---|---|---|
| `project_name` | Project name used for resource naming and tagging | `string` | yes |
| `environment` | Environment identifier (e.g., 'dev', 'staging', 'prod') | `string` | yes |
| `region_short` | Short region code used in naming (e.g., 'use1', 'usw2') | `string` | yes |
| `functions` | Map of Lambda function configurations to create | `map(object({...}))` | no |

See `variables.tf` for the full `functions` object schema and all optional fields with their defaults.

## Outputs

| Name | Description |
|---|---|
| `functions` | Map of created Lambda functions with all attributes |
| `function_arns` | Map of Lambda function ARNs |
| `function_names` | Map of Lambda function names |
| `function_invoke_arns` | Map of Lambda function invoke ARNs |
| `function_role_arns` | Map of Lambda IAM role ARNs |
| `function_role_names` | Map of Lambda IAM role names |
| `function_urls` | Map of Lambda function URLs (if created) |
