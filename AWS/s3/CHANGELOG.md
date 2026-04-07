## [2026-04-07] - Initial Release

### Added
- S3 bucket module wrapping `terraform-aws-modules/s3-bucket/aws` ~> 4.0
- Hardened security defaults: all public access blocked, SSE-AES256 encryption, versioning enabled
- Deny insecure transport and require latest TLS policies enabled by default
- Deny unencrypted object uploads enabled by default
- BucketOwnerEnforced object ownership by default (disables ACLs)
- Support for website hosting, CORS, lifecycle rules, replication, and intelligent tiering
- Standard naming convention: `{project}-{environment}-{region_short}-{key}`
