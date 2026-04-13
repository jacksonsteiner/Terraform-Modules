# Azure Storage Account Module

This module creates Azure Storage Accounts using the Azure Verified Module (AVM) for Storage Accounts.

## Features

- Creates Azure Storage Accounts with secure-by-default configuration
- Supports containers, queues, shares, tables, and Data Lake Gen2 filesystems
- Supports private endpoints for blob, dfs, file, queue, table, and web subresources
- Customer-managed key (CMK) encryption with Key Vault
- Managed identities (system- and user-assigned)
- Diagnostic settings at account and per-service (blob/file/queue/table) level
- Lifecycle management policies
- Resource locks (CanNotDelete/ReadOnly)
- Secure defaults: telemetry disabled, public access disabled, HTTPS only, TLS 1.2, infra encryption, shared key disabled, OAuth default, deny-all network rules

## Usage

```hcl
module "storage_accounts" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//Azure/sa?ref=v1.0.0"

  project_name   = "myproject"
  environment    = "prod"
  location       = "eastus"
  location_short = "eus"

  storage_accounts = {
    data = {
      resource_group_name      = "rg-data-prod-eus"
      account_tier             = "Standard"
      account_replication_type = "LRS"
      access_tier              = "Hot"

      containers = {
        raw = {
          name = "raw"
        }
      }

      private_endpoints = {
        blob = {
          subnet_resource_id            = module.virtual_networks.subnets["hub"]["private-endpoints"].resource_id
          subresource_name              = "blob"
          private_dns_zone_resource_ids = [module.private_dns_zones.pdz_ids["blob"]]
        }
      }

      role_assignments = {
        reader = {
          role_definition_id_or_name = "Storage Blob Data Reader"
          principal_id               = "00000000-0000-0000-0000-000000000000"
        }
      }
    }
  }
}
```

## Outputs

- `storage_accounts` - Map of all created Storage Accounts with full attributes
- `storage_account_ids` - Map of Storage Account resource IDs
- `storage_account_names` - Map of Storage Account names
- `storage_account_fqdns` - Map of service FQDNs per account
- `storage_account_containers` - Map of containers per account
- `storage_account_private_endpoints` - Map of private endpoints per account

## Secure Defaults

| Setting | Default |
|---------|---------|
| `enable_telemetry` | `false` |
| `public_network_access_enabled` | `false` |
| `https_traffic_only_enabled` | `true` |
| `min_tls_version` | `TLS1_2` |
| `infrastructure_encryption_enabled` | `true` |
| `allow_nested_items_to_be_public` | `false` |
| `shared_access_key_enabled` | `false` |
| `default_to_oauth_authentication` | `true` |
| `cross_tenant_replication_enabled` | `false` |
| `account_replication_type` | `LRS` (cost-efficient; use ZRS/GRS when required) |
| `network_rules.default_action` | `Deny` |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| azurerm | ~> 4.0 |

## Resources

This module uses the [Azure Verified Module for Storage Accounts](https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm/latest).
