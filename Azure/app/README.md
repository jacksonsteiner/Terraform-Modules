# Azure AD Application Module

This module creates Azure AD Application Registrations with Service Principals and Federated Identity Credentials.

## Features

- Creates Azure AD Application Registrations
- Creates Service Principals (Enterprise Applications)
- Supports Federated Identity Credentials (Workload Identity)
- Supports API permissions and OAuth2 scopes
- Secure defaults (single tenant, no public client)

## Usage

```hcl
module "applications" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//Azure/app?ref=v1.0.0"

  project_name   = "myproject"
  environment    = "prod"
  location_short = "eus"

  applications = {
    api = {
      display_name     = "My API Application"
      sign_in_audience = "AzureADMyOrg"

      api = {
        requested_access_token_version = 2
      }

      web = {
        redirect_uris = ["https://myapp.example.com/auth/callback"]
        implicit_grant = {
          id_token_issuance_enabled = true
        }
      }
    }
  }
}
```

## Outputs

- `applications` - Map of created Azure AD applications
- `service_principals` - Map of created service principals
- `application_ids` - Map of application IDs
- `client_ids` - Map of client IDs

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| azurerm | ~> 4.0 |
| azuread | ~> 3.0 |
