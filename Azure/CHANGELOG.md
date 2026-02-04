# Changelog

All notable changes to these Azure Terraform modules will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [2026-02-04] - Security, Cost, and Version Updates

### Changed
- Updated `avm-res-resources-resourcegroup` from 0.2.1 to 0.2.2
  - Adds resource group location to outputs
- Updated `avm-res-network-virtualnetwork` from 0.15.0 to 0.17.1
  - Multiple upstream improvements and fixes
- Updated `avm-res-network-privatednszone` from 0.4.3 to 0.4.4
  - Minor upstream fixes

### Security Fixes
- **Key Vault**: Changed `public_network_access_enabled` default from `true` to `false`
  - Aligns with secure-by-default principle
  - Public network access now requires explicit opt-in
  - Consumers should use private endpoints for production workloads

### Added

### Cost Optimizations
- **Key Vault**: Changed `sku_name` default from `"premium"` to `"standard"`
  - Premium SKU (~3x cost) should only be used when HSM-backed keys are required
  - Consumers can explicitly set `sku_name = "premium"` when needed

### Breaking Changes
- Existing Key Vault deployments with default settings will now:
  - Have public network access disabled (may require private endpoint configuration)
  - Use standard SKU instead of premium (no impact unless using HSM keys)
- Consumers relying on previous defaults should explicitly set:
  ```hcl
  kv_foundation = {
    example = {
      public_network_access_enabled = true  # If public access needed
      sku_name                      = "premium"  # If HSM keys needed
    }
  }
  ```
