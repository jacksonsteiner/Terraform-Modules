# Azure Virtual Machine Module

This module creates Azure Virtual Machines using the Azure Verified Module (AVM) for Virtual Machines.

## Features

- Creates one or more Virtual Machines via `for_each`
- Secure defaults: encryption at host, system-assigned managed identity, no public IPs
- Cost-conscious defaults: Standard_D2s_v3 SKU, Linux OS
- Boot diagnostics enabled by default for monitoring
- Supports data disks, extensions, and run commands
- Supports shutdown schedules and Azure Backup
- Supports Spot VM pricing for cost savings
- Supports resource locks (CanNotDelete/ReadOnly)
- Supports RBAC role assignments
- Supports diagnostic settings and monitoring
- Secure defaults (telemetry disabled)

## Usage

```hcl
module "virtual_machines" {
  source = "git::https://github.com/your-org/Terraform-Modules.git//Azure/vm?ref=v1.0.0"

  project_name   = "myproject"
  environment    = "prod"
  location       = "eastus"
  location_short = "eus"

  virtual_machines = {
    web = {
      resource_group_name = "rg-compute-prod-eus"
      zone                = "1"

      source_image_reference = {
        publisher = "Canonical"
        offer     = "ubuntu-24_04-lts"
        sku       = "server"
        version   = "latest"
      }

      account_credentials = {
        admin_username                   = "azureuser"
        generate_admin_password_or_ssh_key = true
      }

      network_interfaces = {
        primary = {
          ip_configurations = {
            primary = {
              private_ip_subnet_resource_id = "/subscriptions/.../subnets/web"
            }
          }
        }
      }
    }
  }
}
```

## Outputs

- `virtual_machines` - Map of all created VMs with full attributes (sensitive)
- `vm_ids` - Map of VM resource IDs (key => resource_id)
- `vm_names` - Map of VM names (key => name)
- `vm_principal_ids` - Map of system-assigned managed identity principal IDs

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| azurerm | ~> 4.0 |

## Notes

- `encryption_at_host_enabled` requires the `EncryptionAtHost` feature to be registered on the subscription
- Either `source_image_reference` or `source_image_resource_id` should be provided for each VM
- The `virtual_machines` output is marked sensitive because it contains credentials and SSH keys

## Resources

This module uses the [Azure Verified Module for Virtual Machines](https://registry.terraform.io/modules/Azure/avm-res-compute-virtualmachine/azurerm/latest).
