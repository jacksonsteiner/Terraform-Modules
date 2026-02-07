# Azure Kubernetes Service (AKS) Module

This module creates AKS managed clusters using the Azure Verified Module (AVM) for Container Service.

## Features

- Creates one or more AKS clusters via `for_each`
- Secure defaults: Azure RBAC, local accounts disabled, Azure Policy enabled
- Key Vault Secrets Provider with automatic secret rotation
- OIDC issuer enabled for workload identity federation
- Network policies enabled with Azure CNI overlay mode
- AzureLinux OS for default agent pool (more secure)
- Auto-scaling enabled with zone-redundant node pools
- Cost-conscious defaults: Free tier SKU, Standard_D2s_v3 nodes, 1-3 auto-scaling
- Automatic patch upgrades for security
- Supports private endpoints and private clusters
- Supports resource locks (CanNotDelete/ReadOnly)
- Supports RBAC role assignments
- Supports diagnostic settings and monitoring
- Secure defaults (telemetry disabled)

## Usage

```hcl
module "aks_clusters" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//Azure/aks?ref=v1.0.0"

  project_name   = "myproject"
  environment    = "prod"
  location       = "eastus"
  location_short = "eus"

  managed_clusters = {
    main = {
      parent_id  = module.resource_groups.resource_group_ids["compute"]
      dns_prefix = "myproject-prod"

      # Override SKU for production SLA
      sku = {
        name = "Base"
        tier = "Standard"
      }

      default_agent_pool = {
        vm_size        = "Standard_D4s_v3"
        min_count      = 2
        max_count      = 5
        vnet_subnet_id = module.virtual_networks.subnets["aks"].resource_id
      }
    }
  }
}
```

## Outputs

- `managed_clusters` - Map of all created AKS clusters with full attributes (sensitive)
- `aks_ids` - Map of AKS cluster resource IDs (key => resource_id)
- `aks_names` - Map of AKS cluster names (key => name)
- `aks_fqdns` - Map of AKS cluster FQDNs (key => fqdn)
- `aks_principal_ids` - Map of system-assigned managed identity principal IDs
- `aks_oidc_issuer_urls` - Map of OIDC issuer URLs for workload identity

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| azurerm | ~> 4.0 |

## Notes

- Free tier has no SLA - use `tier = "Standard"` for production workloads
- `default_agent_pool` uses `merge()` with secure defaults, so you only need to override specific fields
- Network profile defaults to Azure CNI overlay with network policies; provide your own `network_profile` to fully replace
- Workload identity requires `oidc_issuer_profile.enabled = true` (enabled by default)
- The `managed_clusters` output is marked sensitive because it contains kubeconfig credentials

## Resources

This module uses the [Azure Verified Module for AKS](https://registry.terraform.io/modules/Azure/avm-res-containerservice-managedcluster/azurerm/latest).
