# Azure Bastion Module

This module creates Azure Bastion Hosts using the Azure Verified Module (AVM) for Bastion.

## Features

- Creates one or more Azure Bastion Hosts via `for_each`
- Supports multiple SKUs (Basic, Standard, Developer, Premium)
- Automatically configures public IP addresses (non-Developer SKUs)
- Developer SKU support with VNet-only configuration (no public IP required)
- Configures availability zones (defaults to zones 1, 2, 3 for non-Developer SKUs)
- Supports diagnostic settings and monitoring
- Supports resource locks (CanNotDelete/ReadOnly)
- Supports RBAC role assignments
- Secure defaults (telemetry disabled)

## Usage

```hcl
module "bastions" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//Azure/bastion?ref=v1.0.0"

  project_name   = "myproject"
  environment    = "prod"
  location       = "eastus"
  location_short = "eus"

  bastions = {
    hub = {
      parent_id = module.resource_groups.resource_group_ids["networking"]
      subnet_id = module.virtual_networks.subnets["hub"]["AzureBastionSubnet"].resource_id
      sku       = "Basic"

      diagnostic_settings = {
        logs = {
          workspace_resource_id = module.log_analytics.workspace_id
        }
      }
    }
  }
}
```

## Outputs

- `bastions` - Map of all created Bastion Hosts with full attributes
- `bastion_ids` - Map of Bastion Host IDs (key => resource_id)
- `bastion_names` - Map of Bastion Host names (key => name)
- `bastion_dns_names` - Map of Bastion Host FQDNs (key => dns_name)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| azurerm | ~> 4.0 |

## Resources

This module uses the [Azure Verified Module for Bastion Hosts](https://registry.terraform.io/modules/Azure/avm-res-network-bastionhost/azurerm/latest).

## Notes

- The subnet must be named "AzureBastionSubnet" and have a minimum size of /26
- Basic SKU has limited features compared to Standard and Premium
- Developer SKU does not require a subnet or public IP (uses `virtual_network_id` instead)
- Availability zones default to ["1", "2", "3"] for non-Developer SKUs
