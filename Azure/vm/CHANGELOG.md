# Changelog

## [2026-02-07] - Initial Release

### Added
- Initial VM wrapper module wrapping AVM `Azure/avm-res-compute-virtualmachine/azurerm` version `~> 0.20`
- Secure defaults: encryption at host enabled, system-assigned managed identity, no public IPs, boot diagnostics enabled
- Cost-conscious defaults: Standard_D2s_v3 SKU, Linux OS type
- Full passthrough of all upstream AVM variables
- Convenience outputs for resource IDs, names, and managed identity principal IDs
