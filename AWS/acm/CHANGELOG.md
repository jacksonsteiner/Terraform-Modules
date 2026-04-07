## [2026-04-07] - Initial Release

### Added
- ACM certificate module wrapping `terraform-aws-modules/acm/aws` ~> 5.0
- DNS validation by default (preferred over email for automation)
- Certificate Transparency logging enabled by default
- Automatic Route53 validation record creation
- Support for Subject Alternative Names (SANs)
- Support for multiple hosted zones via `zones` parameter
- Standard tagging convention
