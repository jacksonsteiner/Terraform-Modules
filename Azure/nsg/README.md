# Azure Network Security Group Module

This module creates Azure Network Security Groups with security rules using the Azure Verified Module (AVM) for NSGs.

## Features

- Creates one or more Network Security Groups
- Configures security rules for inbound/outbound traffic control
- Supports diagnostic settings and monitoring
- Supports resource locks (CanNotDelete/ReadOnly)
- Supports RBAC role assignments
- Secure defaults (telemetry disabled)

## Usage

```hcl
module "network_security_groups" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//Azure/nsg?ref=v1.0.0"

  project_name   = "myproject"
  environment    = "prod"
  location       = "eastus"
  location_short = "eus"

  network_security_groups = {
    web = {
      resource_group_name = "rg-networking-prod-eus"

      security_rules = {
        allow_https = {
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "Internet"
          destination_address_prefix = "*"
          description                = "Allow HTTPS inbound"
        }
        deny_all_inbound = {
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
          description                = "Deny all other inbound traffic"
        }
      }
    }
  }
}
```

## Outputs

- `network_security_groups` - Map of all created NSGs with full attributes
- `nsg_ids` - Map of NSG IDs (key => resource_id)
- `nsg_names` - Map of NSG names (key => name)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| azurerm | ~> 4.0 |

## Resources

This module uses the [Azure Verified Module for Network Security Groups](https://registry.terraform.io/modules/Azure/avm-res-network-networksecuritygroup/azurerm/latest).
