# AWS IAM Role (OIDC) Module

Wrapper around `terraform-aws-modules/iam/aws//modules/iam-role` (v6.x), the successor to the retired `iam-assumable-role-with-oidc` submodule. Creates IAM roles with OIDC trust policies for federated identity providers such as GitHub Actions and EKS IRSA.

## Features

- Creates IAM roles trusted by OIDC providers (GitHub Actions, EKS, etc.)
- First-class GitHub Actions OIDC support via `enable_github_oidc`
- Supports exact subject matching and wildcard patterns for trust scoping
- Supports audience-based trust conditions
- Attaches managed IAM policies by ARN (map of name => ARN)
- Secure defaults (name-as-prefix disabled, 1 hour max session)

## Usage

### GitHub Actions OIDC (preferred)

```hcl
module "iam_oidc_roles" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//AWS/iam-role?ref=v1.0.0"

  project_name = "myproject"
  environment  = "prod"
  region_short = "use1"

  oidc_roles = {
    github_deploy = {
      enable_github_oidc = true

      oidc_subjects = [
        "repo:my-org/my-repo:ref:refs/heads/main"
      ]
      oidc_audiences = ["sts.amazonaws.com"]

      policies = {
        deploy = "arn:aws:iam::aws:policy/my-deploy-policy"
      }
    }
  }
}
```

### EKS IRSA (IAM Roles for Service Accounts)

```hcl
module "iam_oidc_roles" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//AWS/iam-role?ref=v1.0.0"

  project_name = "myproject"
  environment  = "prod"
  region_short = "use1"

  oidc_roles = {
    app_service_account = {
      oidc_provider_urls = [
        "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE"
      ]

      oidc_subjects = [
        "system:serviceaccount:default:my-app"
      ]

      policies = {
        app = "arn:aws:iam::aws:policy/my-app-policy"
      }
    }
  }
}
```

### Wildcard Subject Matching

```hcl
oidc_roles = {
  github_all_branches = {
    enable_github_oidc = true

    oidc_wildcard_subjects = [
      "repo:my-org/my-repo:*"
    ]
    oidc_audiences = ["sts.amazonaws.com"]

    policies = {
      readonly = "arn:aws:iam::aws:policy/ReadOnlyAccess"
    }
  }
}
```

## Security Defaults

| Setting | Default | Description |
|---------|---------|-------------|
| `create` | `true` | Role is created by default |
| `enable_oidc` | `true` | OIDC trust is enabled |
| `enable_github_oidc` | `false` | Opt-in for GitHub Actions OIDC helper |
| `use_name_prefix` | `false` | Use exact role name, not a prefix |
| `max_session_duration` | `3600` | 1 hour session limit |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `project_name` | Project name for resource naming | `string` | Yes |
| `environment` | Environment identifier (e.g. dev, prod) | `string` | Yes |
| `region_short` | Short region identifier (e.g. use1) | `string` | Yes |
| `oidc_roles` | Map of IAM OIDC role configurations | `map(object)` | No |

### `oidc_roles` object schema

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `create` | `bool` | `true` | Controls whether the role is created |
| `name` | `string` | `null` | Role name; defaults to `<project>-<env>-<region>-<key>` |
| `use_name_prefix` | `bool` | `false` | Treat `name` as a prefix |
| `description` | `string` | `null` | Role description |
| `path` | `string` | `"/"` | IAM path |
| `permissions_boundary` | `string` | `null` | Permissions boundary ARN |
| `max_session_duration` | `number` | `3600` | Max session duration (seconds) |
| `enable_oidc` | `bool` | `true` | Enable generic OIDC trust |
| `enable_github_oidc` | `bool` | `false` | Enable GitHub OIDC helper (sets provider URL) |
| `github_provider` | `string` | `token.actions.githubusercontent.com` | GitHub OIDC provider hostname |
| `oidc_account_id` | `string` | `null` | Account ID of the OIDC provider (defaults to current) |
| `oidc_provider_urls` | `list(string)` | `[]` | Generic OIDC provider URLs (e.g. EKS issuer) |
| `oidc_subjects` | `list(string)` | `[]` | Exact-match `sub` values |
| `oidc_wildcard_subjects` | `list(string)` | `[]` | `sub` values matched with `StringLike` |
| `oidc_audiences` | `list(string)` | `[]` | Accepted `aud` values |
| `policies` | `map(string)` | `{}` | Managed policies to attach (name => ARN) |
| `tags` | `map(string)` | `{}` | Additional tags |

## Outputs

| Name | Description |
|------|-------------|
| `oidc_roles` | Map of created IAM OIDC roles with all attributes |
| `oidc_role_arns` | Map of IAM role ARNs |
| `oidc_role_names` | Map of IAM role names |
| `oidc_role_unique_ids` | Map of IAM role unique IDs |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | >= 6.28.0, < 7.0.0 |
| terraform-aws-modules/iam/aws//modules/iam-role | ~> 6.4.0 |
