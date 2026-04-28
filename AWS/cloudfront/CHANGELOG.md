## [2026-04-19] - Update Module Version

## Changed
- CloudFront distribution module wrapping `terraform-aws-modules/cloudfront/aws` ~> 6.4.1 (latest)

## [2026-04-07] - Initial Release

### Added
- CloudFront distribution module wrapping `terraform-aws-modules/cloudfront/aws` ~> 4.0
- Hardened security defaults: HTTPS redirect, TLSv1.2_2021 minimum, SNI-only
- HTTP/2 and HTTP/3 enabled by default for performance
- Origin Access Control (OAC) for S3 origins by default (replaces legacy OAI)
- WAF integration support via `web_acl_id`
- Support for custom error responses, response headers policies, and CloudFront functions
- Standard naming convention: `{project}-{environment}-{region_short}-{key}`
- Cost-efficient PriceClass_100 default
