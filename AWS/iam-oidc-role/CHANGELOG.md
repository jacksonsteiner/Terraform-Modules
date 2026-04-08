# Changelog

## [2026-04-08] - Initial Release

### Added
- Wrapper module for `terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc` v5.x
- Support for GitHub Actions OIDC, EKS IRSA, and other federated identity providers
- OIDC subject and audience filtering for trust policy scoping
- Policy attachment support via ARN list
- Secure defaults: self-assume disabled, force detach disabled
- Automatic role naming with project/environment/region suffix convention
