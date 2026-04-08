# AWS IAM Assumable Role with OIDC Module

This module creates IAM roles with OIDC trust policies for federated identity providers such as GitHub Actions and EKS IRSA (IAM Roles for Service Accounts).

## Features

- Creates IAM roles trusted by OIDC providers (GitHub Actions, EKS, etc.)
- Supports exact subject matching and wildcard patterns for trust scoping
- Supports audience-based trust conditions
- Attaches IAM policies by ARN
- Secure defaults (self-assume disabled)

## Usage

### GitHub Actions OIDC

```hcl
module "iam_oidc_roles" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//AWS/iam-oidc-role?ref=v1.0.0"

  project_name = "myproject"
  environment  = "prod"
  region_short = "use1"

  oidc_roles = {
    github_deploy = {
      provider_url = "token.actions.githubusercontent.com"

      oidc_fully_qualified_subjects = [
        "repo:my-org/my-repo:ref:refs/heads/main"
      ]
      oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

      role_policy_arns = [
        "arn:aws:iam::policy/my-deploy-policy"
      ]
    }
  }
}
```

### EKS IRSA (IAM Roles for Service Accounts)

```hcl
module "iam_oidc_roles" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//AWS/iam-oidc-role?ref=v1.0.0"

  project_name = "myproject"
  environment  = "prod"
  region_short = "use1"

  oidc_roles = {
    app_service_account = {
      provider_url = "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE"

      oidc_fully_qualified_subjects = [
        "system:serviceaccount:default:my-app"
      ]

      role_policy_arns = [
        "arn:aws:iam::policy/my-app-policy"
      ]
    }
  }
}
```

### Wildcard Subject Matching

```hcl
oidc_roles = {
  github_all_branches = {
    provider_url = "token.actions.githubusercontent.com"

    oidc_subjects_with_wildcards = [
      "repo:my-org/my-repo:*"
    ]
    oidc_fully_qualified_audiences = ["sts.amazonaws.com"]

    role_policy_arns = [
      "arn:aws:iam::policy/my-readonly-policy"
    ]
  }
}
```

## Security Defaults

| Setting | Default | Description |
|---------|---------|-------------|
| `create_role` | `true` | Role is created by default |
| `allow_self_assume_role` | `false` | Role cannot assume itself |
| `force_detach_policies` | `false` | Policies are not force-detached on destroy |
| `max_session_duration` | `3600` | 1 hour session limit |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `oidc_roles` | Map of IAM OIDC role configurations | `map(object)` | No |
| `project_name` | Project name for resource naming | `string` | Yes |
| `environment` | Environment identifier (e.g. dev, prod) | `string` | Yes |
| `region_short` | Short region identifier (e.g. use1) | `string` | Yes |

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
| aws | ~> 5.0 |
| terraform-aws-modules/iam/aws | ~> 5.0 |
