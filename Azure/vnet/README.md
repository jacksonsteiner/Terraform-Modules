# Azure Virtual Network Module

This module creates Azure Virtual Networks with subnets using the Azure Verified Module (AVM) for Virtual Networks.

## Features

- Creates one or more Azure Virtual Networks via `for_each`
- Configures subnets with flexible addressing (static prefixes or IPAM pool allocation)
- Supports VNet peering (including reverse peering)
- Supports Network Security Groups and Route Tables per subnet
- Supports DDoS protection plans and VNet encryption
- Supports diagnostic settings and monitoring
- Supports resource locks (CanNotDelete/ReadOnly)
- Supports RBAC role assignments at VNet and subnet level
- Secure defaults (telemetry disabled, default outbound access disabled for subnets)

## Usage

```hcl
# First create resource group
module "resource_groups" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//Azure/rg?ref=v1.0.0"

  project_name   = "myproject"
  environment    = "prod"
  location       = "eastus"
  location_short = "eus"

  resource_groups = {
    networking = {
      name = "rg-networking-prod-eus"
    }
  }
}

# Then create virtual network
module "virtual_networks" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//Azure/vnet?ref=v1.0.0"

  project_name   = "myproject"
  environment    = "prod"
  location       = "eastus"
  location_short = "eus"

  virtual_networks = {
    hub = {
      parent_id     = module.resource_groups.resource_group_ids["networking"]
      address_space = ["10.0.0.0/16"]

      subnets = {
        AzureBastionSubnet = {
          name           = "AzureBastionSubnet"
          address_prefix = "10.0.0.0/24"
        }
        gateway = {
          address_prefix = "10.0.1.0/24"
        }
        workload = {
          address_prefix = "10.0.2.0/24"
          network_security_group = {
            id = module.nsgs.nsg_ids["workload"]
          }
          service_endpoints_with_location = [
            {
              service   = "Microsoft.Storage"
              locations = ["eastus"]
            }
          ]
        }
      }

      lock = {
        kind = "CanNotDelete"
        name = "prevent-deletion"
      }
    }
  }
}
```

## Outputs

- `virtual_networks` - Map of all created virtual networks with full attributes
- `vnet_ids` - Map of virtual network IDs (key => resource_id)
- `vnet_names` - Map of virtual network names (key => name)
- `vnet_locations` - Map of virtual network locations (key => location)
- `vnet_address_spaces` - Map of virtual network address spaces (key => address_spaces)
- `subnets` - Map of all subnets across all virtual networks (key => subnets)
- `vnet_peerings` - Map of all VNet peerings (key => peerings)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| azurerm | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.0 |

## Resources

This module uses the [Azure Verified Module for Virtual Networks](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm/latest).
