# Azure Resource Group Module

This module creates Azure Resource Groups using the Azure Verified Module (AVM) for Resource Groups.

## Features

- Creates one or more Azure Resource Groups
- Supports resource locks (CanNotDelete/ReadOnly)
- Supports RBAC role assignments
- Supports custom tags
- Secure defaults (telemetry disabled)

## Usage

```hcl
module "resource_groups" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//Azure/rg?ref=v1.0.0"

  project_name   = "myproject"
  environment    = "prod"
  location       = "eastus"
  location_short = "eus"

  resource_groups = {
    networking = {
      name = "rg-networking-prod-eus"
      lock = {
        kind = "CanNotDelete"
        name = "prevent-deletion"
      }
    }
    compute = {
      name = "rg-compute-prod-eus"
      tags = {
        workload = "compute"
      }
    }
  }
}
```

## Outputs

- `resource_groups` - Map of all created resource groups with full attributes
- `resource_group_ids` - Map of resource group IDs (key => resource_id)
- `resource_group_names` - Map of resource group names (key => name)
- `resource_group_locations` - Map of resource group locations (key => location)

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

This module uses the [Azure Verified Module for Resource Groups](https://registry.terraform.io/modules/Azure/avm-res-resources-resourcegroup/azurerm/latest).
