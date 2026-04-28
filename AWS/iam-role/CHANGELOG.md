# Changelog

## [2026-04-19] - Module Update

### Changed
- Migrated underlying source from retired `iam-assumable-role-with-oidc` submodule to `terraform-aws-modules/iam/aws//modules/iam-role` v6.4.0, which consolidates OIDC, GitHub OIDC, Bitbucket OIDC, and SAML trust support into a single submodule.
- Renamed inputs on the `oidc_roles` object schema to match the new upstream variable names.
- Bumped AWS provider constraint from `~> 5.0` to `>= 6.28.0, < 7.0.0` to meet the new upstream submodule's requirements.

### Added
- `enable_oidc` (default `true`) — required in the new upstream module to activate OIDC trust statements.
- `enable_github_oidc` (default `false`) and `github_provider` — first-class GitHub Actions OIDC helper.
- `use_name_prefix` — toggle upstream name-prefix behavior; defaults to `false` to preserve deterministic role names.

### Deprecated / Renamed

| Old input | New input |
|-----------|-----------|
| `role_name` | `name` |
| `role_name_prefix` | `use_name_prefix` + `name` |
| `role_description` | `description` |
| `role_path` | `path` |
| `role_permissions_boundary_arn` | `permissions_boundary` |
| `provider_url` / `provider_urls` | `oidc_provider_urls` |
| `aws_account_id` | `oidc_account_id` |
| `oidc_fully_qualified_subjects` | `oidc_subjects` |
| `oidc_subjects_with_wildcards` | `oidc_wildcard_subjects` |
| `oidc_fully_qualified_audiences` | `oidc_audiences` |
| `role_policy_arns` (list) | `policies` (map of name => ARN) |
| `create_role` | `create` |

### Removed
- `number_of_role_policy_arns` — no longer required (the new module derives it automatically).
- `allow_self_assume_role` and `force_detach_policies` — not exposed by the new upstream submodule.

### Breaking Changes
- All consumers must rename the variables listed above.
- `role_policy_arns` must be rewritten from a list of ARNs to a `policies` map of `{ name = arn }`.
- Roles previously relying on `oidc_fully_qualified_audiences` now must set `oidc_audiences` and, for non-GitHub providers, also set `enable_oidc = true` (the default) and `oidc_provider_urls`.

## [2026-04-08] - Initial Release

### Added
- Wrapper module for `terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc` v5.x
- Support for GitHub Actions OIDC, EKS IRSA, and other federated identity providers
- OIDC subject and audience filtering for trust policy scoping
- Policy attachment support via ARN list
- Secure defaults: self-assume disabled, force detach disabled
- Automatic role naming with project/environment/region suffix convention
