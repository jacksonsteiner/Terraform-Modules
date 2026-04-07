## [2026-04-07] - Initial Release

### Added
- Lambda function module wrapping `terraform-aws-modules/lambda/aws` ~> 7.0
- Hardened security defaults: X-Ray tracing active, AWS_IAM auth for function URLs
- ARM64 architecture by default for cost efficiency
- CloudWatch Logs with 30-day retention by default
- Automatic VPC network policy attachment when VPC configured
- Automatic dead letter policy attachment when DLQ configured
- Support for KMS encryption, code signing, layers, and event source mappings
- Standard naming convention: `{project}-{environment}-{region_short}-{key}`
