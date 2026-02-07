# Changelog

## [2026-02-07] - Initial Release

### Added
- Initial AKS wrapper module wrapping AVM `Azure/avm-res-containerservice-managedcluster/azurerm` version `~> 0.4`
- Secure defaults: local accounts disabled, RBAC enabled, Azure AD managed integration, Azure Policy, Key Vault secrets provider with rotation, OIDC issuer for workload identity, network policies enabled, AzureLinux OS
- Cost-conscious defaults: Free tier SKU, Standard_D2s_v3 node size, 1-3 node auto-scaling
- Full passthrough of all upstream AVM variables
- Convenience outputs for resource IDs, names, FQDNs, principal IDs, and OIDC issuer URLs
