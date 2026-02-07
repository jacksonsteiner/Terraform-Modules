# Azure Private DNS Zone Module

This module creates Azure Private DNS Zones with virtual network links using the Azure Verified Module (AVM).

## Features

- Creates Private DNS Zones
- Configures DNS records (A, AAAA, CNAME, MX, PTR, SRV, TXT)
- Links Private DNS Zones to Virtual Networks
- Supports auto-registration
- Supports resource locks (CanNotDelete/ReadOnly)
- Supports RBAC role assignments
- Secure defaults (telemetry disabled)

## Usage

```hcl
module "private_dns_zones" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//Azure/pdz?ref=v1.0.0"

  project_name   = "myproject"
  environment    = "prod"
  location       = "eastus"
  location_short = "eus"

  private_dns_zones = {
    keyvault = {
      parent_id   = module.resource_groups.resource_group_ids["networking"]
      domain_name = "privatelink.vaultcore.azure.net"

      virtual_network_links = {
        hub = {
          vnetid           = module.virtual_networks.vnet_ids["hub"]
          autoregistration = false
        }
      }
    }
  }
}
```

## Outputs

- `private_dns_zones` - Map of created private DNS zones with full attributes
- `pdz_ids` - Map of private DNS zone IDs
- `pdz_names` - Map of private DNS zone names

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| azurerm | ~> 4.0 |

## Resources

This module uses the [Azure Verified Module for Private DNS Zones](https://registry.terraform.io/modules/Azure/avm-res-network-privatednszone/azurerm/latest).
