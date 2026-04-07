# DynamoDB Table Module

Terraform module for creating hardened AWS DynamoDB tables. Wraps the community module [`terraform-aws-modules/dynamodb-table/aws`](https://registry.terraform.io/modules/terraform-aws-modules/dynamodb-table/aws/latest) version ~> 4.0 with secure defaults and a standardized naming convention.

## Features

- **Encryption at rest** enabled by default (server-side encryption)
- **Point-in-Time Recovery (PITR)** enabled by default for data protection
- **Deletion protection** enabled by default to prevent accidental table removal
- **PAY_PER_REQUEST** billing by default for cost efficiency
- **Autoscaling** support for provisioned capacity tables
- **Global Secondary Indexes (GSI)** and **Local Secondary Indexes (LSI)**
- **DynamoDB Streams** for change data capture
- **TTL** for automatic item expiration
- **Global Tables** via replica regions
- Standard naming convention: `{project}-{environment}-{region_short}-{key}`

## Usage

```hcl
module "dynamodb" {
  source = "../../AWS/dynamodb"

  project_name = "blog"
  environment  = "prod"
  region_short = "use1"

  tables = {
    comments = {
      hash_key  = "post_id"
      range_key = "comment_id"

      attributes = [
        { name = "post_id", type = "S" },
        { name = "comment_id", type = "S" },
        { name = "author", type = "S" },
      ]

      ttl_enabled        = true
      ttl_attribute_name = "expires_at"

      global_secondary_indexes = [
        {
          name            = "AuthorIndex"
          hash_key        = "author"
          projection_type = "ALL"
        }
      ]
    }

    visitors = {
      hash_key = "visitor_id"

      attributes = [
        { name = "visitor_id", type = "S" },
      ]

      stream_enabled   = true
      stream_view_type = "NEW_AND_OLD_IMAGES"
    }
  }
}
```

This creates two tables:
- `blog-prod-use1-comments` with a GSI on `author` and TTL enabled
- `blog-prod-use1-visitors` with DynamoDB Streams enabled

## Security Defaults

| Setting | Default | Description |
|---|---|---|
| `server_side_encryption_enabled` | `true` | Encryption at rest using AWS managed or customer-managed KMS key |
| `point_in_time_recovery_enabled` | `true` | Continuous backups with point-in-time restore (up to 35 days) |
| `deletion_protection_enabled` | `true` | Prevents accidental table deletion via API or console |
| `billing_mode` | `PAY_PER_REQUEST` | On-demand capacity for cost efficiency; no capacity planning needed |

To override any hardened default, explicitly set the value in the table configuration:

```hcl
tables = {
  scratch = {
    hash_key   = "id"
    attributes = [{ name = "id", type = "S" }]

    deletion_protection_enabled    = false
    point_in_time_recovery_enabled = false
  }
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.6.0 |
| aws | ~> 5.0 |

## Inputs

| Name | Type | Required | Description |
|---|---|---|---|
| `project_name` | `string` | yes | Project name used for resource naming and tagging |
| `environment` | `string` | yes | Environment identifier (e.g., `dev`, `staging`, `prod`) |
| `region_short` | `string` | yes | Short region code used in naming (e.g., `use1`, `usw2`) |
| `tables` | `map(object({...}))` | yes | Map of DynamoDB table configurations to create |

### `tables` Object Fields

| Field | Type | Default | Description |
|---|---|---|---|
| `hash_key` | `string` | (required) | Partition key attribute name |
| `attributes` | `list(object)` | (required) | Key schema attributes (`name` and `type`) |
| `name` | `string` | `null` | Custom table name (overrides generated name) |
| `range_key` | `string` | `null` | Sort key attribute name |
| `billing_mode` | `string` | `"PAY_PER_REQUEST"` | Billing mode (`PAY_PER_REQUEST` or `PROVISIONED`) |
| `read_capacity` | `number` | `null` | Read capacity units (required if `PROVISIONED`) |
| `write_capacity` | `number` | `null` | Write capacity units (required if `PROVISIONED`) |
| `table_class` | `string` | `null` | Table class (`STANDARD` or `STANDARD_INFREQUENT_ACCESS`) |
| `tags` | `map(string)` | `null` | Additional tags to merge with defaults |
| `server_side_encryption_enabled` | `bool` | `true` | Enable server-side encryption |
| `server_side_encryption_kms_key_arn` | `string` | `null` | KMS key ARN for encryption |
| `point_in_time_recovery_enabled` | `bool` | `true` | Enable point-in-time recovery |
| `deletion_protection_enabled` | `bool` | `true` | Enable deletion protection |
| `stream_enabled` | `bool` | `false` | Enable DynamoDB Streams |
| `stream_view_type` | `string` | `null` | Stream view type (`KEYS_ONLY`, `NEW_IMAGE`, `OLD_IMAGE`, `NEW_AND_OLD_IMAGES`) |
| `ttl_enabled` | `bool` | `false` | Enable TTL |
| `ttl_attribute_name` | `string` | `""` | TTL attribute name |
| `global_secondary_indexes` | `any` | `[]` | List of GSI configurations |
| `local_secondary_indexes` | `any` | `[]` | List of LSI configurations |
| `replica_regions` | `any` | `[]` | Replica region configurations for global tables |
| `autoscaling_enabled` | `bool` | `false` | Enable autoscaling |
| `autoscaling_defaults` | `map(string)` | `null` | Default autoscaling settings |
| `autoscaling_read` | `map(string)` | `{}` | Read autoscaling settings |
| `autoscaling_write` | `map(string)` | `{}` | Write autoscaling settings |
| `autoscaling_indexes` | `map(map(string))` | `{}` | Per-index autoscaling settings |
| `timeouts` | `map(string)` | `null` | Custom timeouts for create/update/delete |
| `resource_policy` | `string` | `null` | Resource-based policy JSON |

## Outputs

| Name | Description |
|---|---|
| `tables` | Map of created DynamoDB tables with all attributes |
| `table_arns` | Map of DynamoDB table ARNs |
| `table_ids` | Map of DynamoDB table IDs |
| `table_stream_arns` | Map of DynamoDB table stream ARNs |
