# Changelog

## [2026-04-13] - Initial Release

### Added
- New `sa` module wrapping `Azure/avm-res-storage-storageaccount/azurerm` `~> 0.6`
- Map-based input (`storage_accounts`) consistent with other modules in this repo
- Exposes containers, queues, shares, tables, Data Lake Gen2 filesystems, management policies, private endpoints, diagnostic settings, role assignments, managed identities, and customer-managed keys
- Secure defaults overriding AVM defaults:
  - `enable_telemetry = false`
  - `public_network_access_enabled = false`
  - `infrastructure_encryption_enabled = true`
  - `shared_access_key_enabled = false`
  - `default_to_oauth_authentication = true`
  - `cross_tenant_replication_enabled = false`
  - `allow_nested_items_to_be_public = false`
  - `https_traffic_only_enabled = true`, `min_tls_version = "TLS1_2"`
  - `network_rules.default_action = "Deny"` with `AzureServices` bypass
- Cost-efficient defaults:
  - `account_tier = "Standard"`, `account_replication_type = "LRS"`, `access_tier = "Hot"`
- Standard outputs: `storage_account_ids`, `storage_account_names`, `storage_account_fqdns`, `storage_account_containers`, `storage_account_private_endpoints`

### Notes
- The whole-module passthrough output is intentionally omitted: the upstream AVM module exposes `primary_access_key` as an ephemeral value, so passing the entire module through would force the output to be `ephemeral = true` and break normal downstream consumers.
