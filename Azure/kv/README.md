# Azure Key Vault Module

This module creates Azure Key Vaults using the Azure Verified Module (AVM) for Key Vaults.

## Features

- Creates Azure Key Vaults with RBAC or legacy access policies
- Supports private endpoints for secure access
- Manages keys, secrets, and certificates
- Supports diagnostic settings and monitoring
- Supports resource locks (CanNotDelete/ReadOnly)
- Secure defaults (telemetry disabled, public access disabled, purge protection enabled)

## Usage

```hcl
module "key_vaults" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//Azure/kv?ref=v1.0.0"

  project_name   = "myproject"
  environment    = "prod"
  location       = "eastus"
  location_short = "eus"

  key_vaults = {
    main = {
      resource_group_name           = "rg-security-prod-eus"
      sku_name                      = "standard"
      purge_protection_enabled      = true
      public_network_access_enabled = false
      soft_delete_retention_days    = 90

      role_assignments = {
        admin = {
          role_definition_id_or_name = "Key Vault Administrator"
          principal_id               = "00000000-0000-0000-0000-000000000000"
        }
      }

      private_endpoints = {
        main = {
          subnet_resource_id        = module.virtual_networks.subnets["hub"]["private-endpoints"].resource_id
          private_dns_zone_resource_ids = [module.private_dns_zones.pdz_ids["keyvault"]]
        }
      }

      secrets = {
        example = {
          name = "example-secret"
        }
      }
      secrets_value = {
        example = "sensitive-value"
      }
    }
  }
}
```

## Outputs

- `key_vaults` - Map of all created Key Vaults with full attributes
- `key_vault_ids` - Map of Key Vault resource IDs (key => resource_id)
- `key_vault_names` - Map of Key Vault names (key => name)
- `key_vault_uris` - Map of Key Vault URIs (key => uri)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| azurerm | ~> 4.0 |

## Resources

This module uses the [Azure Verified Module for Key Vaults](https://registry.terraform.io/modules/Azure/avm-res-keyvault-vault/azurerm/latest).
