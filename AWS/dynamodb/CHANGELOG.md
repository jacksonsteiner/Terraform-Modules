## [2026-04-19] - Update Module Version

## Changed
- DynamoDB table module wrapping `terraform-aws-modules/dynamodb-table/aws` ~> 5.5.0 (latest)

## [2026-04-07] - Initial Release

### Added
- DynamoDB table module wrapping `terraform-aws-modules/dynamodb-table/aws` ~> 4.0
- Hardened security defaults: encryption enabled, PITR enabled, deletion protection enabled
- PAY_PER_REQUEST billing by default for cost efficiency
- Support for GSI, LSI, streams, TTL, and autoscaling
- Support for global tables via replica regions
- Standard naming convention: `{project}-{environment}-{region_short}-{key}`
