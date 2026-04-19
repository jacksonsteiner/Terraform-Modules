## [2026-04-19] - Update Module Version

## Changed
- API Gateway v2 module wrapping `terraform-aws-modules/apigateway-v2/aws` ~> 6.1.0 (latest)

## [2026-04-07] - Initial Release

### Added
- API Gateway v2 module wrapping `terraform-aws-modules/apigateway-v2/aws` ~> 5.0
- Hardened security defaults: default execute-api endpoint disabled, forcing custom domain usage
- Support for HTTP and WebSocket APIs
- Access logging support for audit trails
- Mutual TLS authentication support
- Authorizer support (JWT, Lambda, IAM)
- Custom domain with Route53 and ACM integration
- VPC Link support for private integrations
- Standard naming convention: `{project}-{environment}-{region_short}-{key}`
