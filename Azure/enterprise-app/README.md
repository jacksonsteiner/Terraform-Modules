# Azure Enterprise Application Module

This module creates Azure AD Enterprise Applications (Service Principals) from existing app registrations, along with app role assignments and OAuth2 delegated permission grants.

> **Note:** This module is distinct from the `app` module. Use `app` when you need to create an app registration and its service principal together. Use this module when the app registration already exists (your own, a Microsoft first-party app, or a gallery app) and you need to manage its enterprise application, role assignments, or API permission grants.

## Features

- Creates Enterprise Applications (Service Principals) from existing client IDs
- Supports app role assignments for users, groups, and service principals
- Supports admin consent grants for OAuth2 delegated permission scopes (e.g. Microsoft Graph)
- Configurable SSO mode (SAML, OIDC, password)
- Secure defaults (assignment required off, account enabled)

## Usage

### Basic Enterprise Application

```hcl
module "enterprise_app" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//Azure/enterprise-app?ref=v1.0.0"

  project_name   = "myproject"
  environment    = "prod"
  location_short = "eus"

  enterprise_applications = {
    my_app = {
      client_id                  = "00000000-0000-0000-0000-000000000000"
      app_role_assignment_required = true
    }
  }
}
```

### With Microsoft Graph Delegated Permissions

```hcl
module "enterprise_app" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//Azure/enterprise-app?ref=v1.0.0"

  project_name   = "myproject"
  environment    = "prod"
  location_short = "eus"

  enterprise_applications = {
    my_app = {
      client_id = "00000000-0000-0000-0000-000000000000"

      delegated_permission_grants = {
        graph = {
          # Object ID of the client service principal being granted access
          client_service_principal_object_id = "00000000-0000-0000-0000-000000000001"
          # Microsoft Graph delegated scopes
          claim_values = ["openid", "profile", "email"]
        }
      }
    }
  }
}
```

### With App Role Assignments

```hcl
enterprise_applications = {
  my_app = {
    client_id                  = "00000000-0000-0000-0000-000000000000"
    app_role_assignment_required = true

    app_role_assignments = {
      admins = {
        principal_object_id = "00000000-0000-0000-0000-000000000002" # Group object ID
        app_role_id         = "00000000-0000-0000-0000-000000000003" # App role ID
      }
    }
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `enterprise_applications` | Map of enterprise applications to create | `map(object)` | No |
| `project_name` | Project name used for resource naming | `string` | Yes |
| `environment` | Environment identifier (e.g. dev, prod) | `string` | Yes |
| `location_short` | Short location identifier (e.g. eus) | `string` | Yes |

### enterprise_applications object

| Field | Description | Type | Default |
|-------|-------------|------|---------|
| `client_id` | Client ID of the app registration | `string` | required |
| `display_name` | Display name override | `string` | null |
| `description` | Description | `string` | null |
| `account_enabled` | Whether the service principal account is enabled | `bool` | `true` |
| `app_role_assignment_required` | Require explicit user/group assignment | `bool` | `false` |
| `login_url` | Login URL for SAML SSO | `string` | null |
| `notification_email_addresses` | Email addresses for certificate expiry notifications | `set(string)` | `[]` |
| `owners` | Object IDs of owners | `set(string)` | null |
| `preferred_single_sign_on_mode` | SSO mode: `saml`, `oidc`, `password`, `notSupported` | `string` | null |
| `tags` | Tags for the service principal | `set(string)` | null |
| `app_role_assignments` | Map of app role assignments | `map(object)` | `{}` |
| `delegated_permission_grants` | Map of OAuth2 delegated permission grants | `map(object)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `service_principals` | Map of created service principal resources |
| `service_principal_object_ids` | Map of service principal object IDs |
| `service_principal_client_ids` | Map of service principal client IDs |
| `app_role_assignments` | Map of created app role assignment resources |
| `delegated_permission_grants` | Map of created delegated permission grant resources |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| azuread | ~> 3.0 |
