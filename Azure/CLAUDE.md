# Terraform Standards with Azure Verified Modules

This document defines Terraform standards, Azure Verified Module (AVM) usage patterns, and security considerations for reusable Azure infrastructure modules.

---

## Claude Instructions

### Periodic AVM Update Checks

When working in this repository, **periodically check for updates** to the upstream Azure Verified Modules:

1. **Check upstream sources** - Visit the GitHub repositories for each AVM module used in this project to identify new versions, changed variables, or deprecated features
2. **Compare with local modules** - Review local module implementations against the latest AVM `variables.tf` and `main.tf` files
3. **Identify gaps** - Note any new variables, security features, or best practices that should be incorporated

### Changelog Requirements

When updating local modules based on AVM changes, **always update the CHANGELOG.md**:

```markdown
## [YYYY-MM-DD] - Module Update

### Changed
- Updated `module-name` to align with AVM version x.x.x
- Added new variable `variable_name` for [purpose]

### Added
- New security feature: [description]
- Support for [new capability]

### Deprecated
- Variable `old_var` replaced by `new_var`

### Breaking Changes
- [Any breaking changes that require consumer updates]
```

**Update workflow:**
1. Fetch latest AVM module version and review changes
2. Update local module code to incorporate changes
3. Update CHANGELOG.md with all modifications
4. Run `terraform fmt` and `terraform validate`
5. Test changes before committing

### Cloud Security Best Practices

When creating or updating modules, **always follow secure-by-default principles**:

**Secure Default Values**

Always set variable defaults to the most secure option. Consumers can explicitly opt-in to less secure configurations when needed.

| Setting | Secure Default | Insecure (avoid as default) |
|---------|---------------|----------------------------|
| Module telemetry | `false` | `true` (AVM default) |
| Public network access | `false` | `true` |
| HTTPS only | `true` | `false` |
| TLS version | `"TLS1_2"` or higher | `"TLS1_0"`, `"TLS1_1"` |
| Purge protection | `true` | `false` |
| Soft delete | `true` with 90 days | `false` or short retention |
| RBAC authorization | `true` | `false` (access policies) |
| Infrastructure encryption | `true` | `false` |
| Public blob access | `false` | `true` |

**Disabling AVM Telemetry:**

Azure Verified Modules include telemetry that sends deployment data to Microsoft by default. **Always disable telemetry** in module configurations to prevent data exfiltration and maintain privacy:

```hcl
module "example" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "~> 0.10"

  enable_telemetry = false  # Always disable - prevents data sent to Microsoft
  # ... other configuration
}
```

When wrapping AVM modules, expose and default `enable_telemetry` to `false`:

```hcl
variable "enable_telemetry" {
  description = "Disable telemetry collection by Microsoft. Defaults to false for privacy."
  type        = bool
  default     = false  # Override AVM default of true
}
```

**Example - Secure Variable Defaults:**
```hcl
variable "enable_telemetry" {
  description = "Enable module telemetry. Defaults to false for privacy."
  type        = bool
  default     = false  # Secure default - no data sent externally
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled. Defaults to false for security."
  type        = bool
  default     = false  # Secure default - require explicit opt-in for public access
}

variable "min_tls_version" {
  description = "Minimum TLS version. Defaults to TLS 1.2."
  type        = string
  default     = "TLS1_2"  # Secure default - modern TLS only
}

variable "enable_rbac_authorization" {
  description = "Use RBAC for authorization instead of access policies."
  type        = bool
  default     = true  # Secure default - RBAC is preferred
}
```

**Security Principles for Module Development:**

1. **Disable telemetry** - Always set `enable_telemetry = false` to prevent data exfiltration to external parties
2. **Deny by default** - Network access, public endpoints, and permissive settings should be disabled by default
3. **Encryption everywhere** - Enable encryption at rest and in transit by default
4. **Least privilege** - Default to minimal permissions; use RBAC over broad access policies
5. **Defense in depth** - Layer security controls (NSG + private endpoints + firewalls)
6. **Audit everything** - Enable diagnostic settings and logging by default where possible
7. **Protect against deletion** - Consider resource locks for critical infrastructure
8. **Use managed identities** - Prefer managed identities over credentials/keys

**When Reviewing or Creating Modules, Ask:**

- Is `enable_telemetry` set to `false` by default?
- Are public endpoints disabled by default?
- Is encryption enabled by default?
- Are secure protocol versions enforced (TLS 1.2+)?
- Is RBAC used instead of legacy access controls?
- Are diagnostic settings configurable?
- Are private endpoints supported and documented?
- Do defaults align with Azure Security Benchmark and CIS controls?

**Azure Security Benchmark Alignment:**

Modules should align with the [Azure Security Benchmark](https://learn.microsoft.com/en-us/security/benchmark/azure/overview) controls:
- NS (Network Security) - Private endpoints, NSGs, no public access
- IM (Identity Management) - Managed identities, RBAC
- PA (Privileged Access) - Least privilege, JIT access
- DP (Data Protection) - Encryption at rest and in transit
- LT (Logging and Threat Detection) - Diagnostic settings, monitoring

### Cost-Conscious Infrastructure

Balance security requirements with cost efficiency. Secure defaults should not unnecessarily increase cloud spend.

**Cost-Aware Default Values:**

| Resource | Cost-Efficient Default | Expensive (justify if needed) |
|----------|----------------------|------------------------------|
| Key Vault SKU | `"standard"` | `"premium"` (only for HSM keys) |
| Bastion SKU | `"Basic"` | `"Standard"` (only if features needed) |
| VM size | Smallest meeting requirements | Oversized instances |
| Storage tier | `"Hot"` or `"Cool"` based on access | `"Premium"` (only for high IOPS) |
| Redundancy | `"LRS"` for non-critical | `"GRS"`/`"ZRS"` (only if required) |
| Reserved capacity | Consider for stable workloads | Pay-as-you-go for variable |
| Log retention | 30-90 days | 365+ days (only if compliance requires) |

**Cost Principles:**

1. **Right-size by default** - Use smallest SKUs/tiers that meet requirements; allow consumers to scale up
2. **Avoid premium unless justified** - Premium SKUs (HSM, Premium storage) should require explicit opt-in
3. **Consider lifecycle** - Use appropriate storage tiers, retention periods, and auto-shutdown where applicable
4. **Expose cost levers** - Allow consumers to configure SKUs, redundancy, and retention via variables
5. **Document cost implications** - Note in variable descriptions when options significantly impact cost

**Example - Cost-Conscious Variables:**
```hcl
variable "sku_name" {
  description = "Key Vault SKU. Use 'premium' only if HSM-backed keys are required (higher cost)."
  type        = string
  default     = "standard"  # Cost-efficient default
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU must be 'standard' or 'premium'."
  }
}

variable "log_retention_days" {
  description = "Days to retain logs. Longer retention increases storage costs."
  type        = number
  default     = 30  # Balance compliance with cost
}

variable "redundancy_type" {
  description = "Storage redundancy. GRS/ZRS cost more but provide geo/zone redundancy."
  type        = string
  default     = "LRS"  # Cost-efficient for non-critical data
}
```

**Security vs Cost Trade-offs:**

| Security Feature | Cost Impact | Recommendation |
|-----------------|-------------|----------------|
| Private endpoints | ~$7-10/month each | Required for PaaS - security justifies cost |
| Bastion Host | ~$140/month (Basic) | Required - eliminates public IP exposure |
| Key Vault Premium | ~3x Standard cost | Only for HSM requirements |
| Diagnostic settings | Storage/Log Analytics costs | Enable for audit - security justifies cost |
| Geo-redundant storage | ~2x LRS cost | Based on DR requirements |
| DDoS Protection | ~$3000/month | Only for public-facing critical apps |

**When Reviewing or Creating Modules for Cost:**

- Are SKU/tier defaults set to the minimum that meets requirements?
- Are expensive features (premium, geo-redundancy) opt-in rather than default?
- Are retention periods reasonable (not excessively long)?
- Are cost implications documented in variable descriptions?
- Can consumers easily adjust cost-impacting settings?

---

## Azure Verified Modules (AVM) Standards

When writing Azure Terraform code, always use Azure Verified Modules from the official registry when available.

**Module source format:**
```hcl
source  = "Azure/<module-name>/azurerm"
version = "~> x.x"
```

**Registry and documentation:**
- Terraform Registry: https://registry.terraform.io/namespaces/Azure
- AVM Module Index: https://azure.github.io/Azure-Verified-Modules/indexes/terraform/
- GitHub Organization: https://github.com/Azure/terraform-azurerm-modules

### AVM Module Sources

| Resource Type | GitHub Repository | Variables Reference |
|---------------|-------------------|---------------------|
| Resource Group | [terraform-azurerm-avm-res-resources-resourcegroup](https://github.com/Azure/terraform-azurerm-avm-res-resources-resourcegroup) | [variables.tf](https://github.com/Azure/terraform-azurerm-avm-res-resources-resourcegroup/blob/main/variables.tf) |
| Virtual Network | [terraform-azurerm-avm-res-network-virtualnetwork](https://github.com/Azure/terraform-azurerm-avm-res-network-virtualnetwork) | [variables.tf](https://github.com/Azure/terraform-azurerm-avm-res-network-virtualnetwork/blob/main/variables.tf) |
| Bastion Host | [terraform-azurerm-avm-res-network-bastionhost](https://github.com/Azure/terraform-azurerm-avm-res-network-bastionhost) | [variables.tf](https://github.com/Azure/terraform-azurerm-avm-res-network-bastionhost/blob/main/variables.tf) |
| Key Vault | [terraform-azurerm-avm-res-keyvault-vault](https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault) | [variables.tf](https://github.com/Azure/terraform-azurerm-avm-res-keyvault-vault/blob/main/variables.tf) |
| Private DNS Zone | [terraform-azurerm-avm-res-network-privatednszone](https://github.com/Azure/terraform-azurerm-avm-res-network-privatednszone) | [variables.tf](https://github.com/Azure/terraform-azurerm-avm-res-network-privatednszone/blob/main/variables.tf) |
| Virtual Machine | [terraform-azurerm-avm-res-compute-virtualmachine](https://github.com/Azure/terraform-azurerm-avm-res-compute-virtualmachine) | [variables.tf](https://github.com/Azure/terraform-azurerm-avm-res-compute-virtualmachine/blob/main/variables.tf) |
| Network Security Group | [terraform-azurerm-avm-res-network-networksecuritygroup](https://github.com/Azure/terraform-azurerm-avm-res-network-networksecuritygroup) | [variables.tf](https://github.com/Azure/terraform-azurerm-avm-res-network-networksecuritygroup/blob/main/variables.tf) |
| Storage Account | [terraform-azurerm-avm-res-storage-storageaccount](https://github.com/Azure/terraform-azurerm-avm-res-storage-storageaccount) | [variables.tf](https://github.com/Azure/terraform-azurerm-avm-res-storage-storageaccount/blob/main/variables.tf) |
| Log Analytics | [terraform-azurerm-avm-res-operationalinsights-workspace](https://github.com/Azure/terraform-azurerm-avm-res-operationalinsights-workspace) | [variables.tf](https://github.com/Azure/terraform-azurerm-avm-res-operationalinsights-workspace/blob/main/variables.tf) |

### Common AVM Interface Variables

Most AVM modules include these standard interface variables (check `variables.interfaces.tf` if present):
- `enable_telemetry` - Module telemetry (default: true, recommend setting to false)
- `lock` - Resource lock configuration
- `role_assignments` - Azure RBAC assignments
- `diagnostic_settings` - Azure Monitor diagnostic settings
- `private_endpoints` - Private endpoint configuration
- `tags` - Resource tags

### Version Pinning Strategy

```hcl
# Use pessimistic constraint to allow patch updates
version = "~> 0.10"  # Allows 0.10.x but not 0.11.0

# For production stability, pin to exact version
version = "0.10.2"   # Exact version, no automatic updates
```

### Module Usage Rules

1. **Search for an AVM module first** before writing raw `azurerm_*` resources
2. **Always pin module versions** using `version = "~> x.x"` constraints
3. **Check module inputs** at the Terraform Registry for required and optional variables
4. **Use module outputs** to reference resource attributes rather than data sources
5. **Expose all security-relevant variables** to allow consumers to configure security settings

### When AVM Modules Don't Exist

If no verified module exists for a resource:
1. Use the standard `azurerm` provider resource
2. Follow consistent naming conventions
3. Add a comment noting no AVM module was available

```hcl
# No AVM module available for this resource type
resource "azurerm_example_resource" "this" {
  name = var.name
  # ...
}
```

---

## General Terraform Best Practices

- Use `terraform fmt` before committing
- Run `terraform validate` to check syntax
- Store state remotely with state locking enabled
- Keep provider versions pinned
- Apply resource locks (`CanNotDelete`) to critical resources
- Use private endpoints for Azure PaaS services
- Store secrets in Key Vault, never in code or tfvars

---

## Security Considerations with Azure Verified Modules

AVM modules are designed with security best practices built-in. Always leverage these security features.

### Network Security

**Private Endpoints (Required for PaaS Services)**
```hcl
module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "~> 0.10"

  # Disable public network access
  public_network_access_enabled = false

  # Configure private endpoint
  private_endpoints = {
    primary = {
      subnet_resource_id            = var.subnet_resource_id
      private_dns_zone_resource_ids = var.private_dns_zone_ids
    }
  }
}
```

**Network Security Groups**
- Default deny all inbound traffic
- Explicit allow rules only for required ports
- Use service tags instead of IP addresses where possible
- Enable NSG flow logs for auditing

```hcl
module "nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.5"

  security_rules = {
    deny_all_inbound = {
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}
```

**Bastion Host for Secure Access**
- Never expose VM management ports (RDP/SSH) to the internet
- Use Azure Bastion for all administrative access
- Enable Bastion Standard SKU for advanced features

### Identity and Access Management

**Managed Identity (Preferred)**
```hcl
module "virtual_machine" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "~> 0.20"

  managed_identities = {
    system_assigned = true
  }
}
```

**RBAC Role Assignments via AVM**
```hcl
module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "~> 0.10"

  role_assignments = {
    secrets_user = {
      role_definition_id_or_name = "Key Vault Secrets User"
      principal_id               = var.principal_id
    }
  }
}
```

**Key Vault Access**
- Use RBAC authorization over access policies (modern approach)
- Grant minimum required permissions
- Prefer managed identity over service principals

### Data Protection

**Key Vault Security**
```hcl
module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "~> 0.10"

  purge_protection_enabled   = true
  soft_delete_retention_days = 90
  enable_rbac_authorization  = true
  sku_name                   = "premium"  # HSM-backed keys
}
```

**Storage Account Security**
```hcl
module "storage" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.5"

  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  infrastructure_encryption_enabled = true
}
```

### Resource Protection

**Resource Locks**
```hcl
module "resource_group" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "~> 0.2"

  lock = {
    kind = "CanNotDelete"
    name = "prevent-deletion"
  }
}
```

### Monitoring and Auditing

**Diagnostic Settings via AVM**
```hcl
diagnostic_settings = {
  to_log_analytics = {
    workspace_resource_id = var.log_analytics_workspace_id
    log_categories        = ["AuditEvent"]
    metric_categories     = ["AllMetrics"]
  }
}
```

### Security Checklist for AVM Modules

| Security Control | Implementation |
|-----------------|----------------|
| Private Endpoints | Use `private_endpoints` variable for all PaaS services |
| Managed Identity | Set `managed_identities.system_assigned = true` |
| RBAC | Use `role_assignments` variable instead of direct assignments |
| Resource Locks | Use `lock` variable with `CanNotDelete` for critical resources |
| Diagnostic Settings | Configure `diagnostic_settings` for all resources |
| Encryption | Enable customer-managed keys where supported |
| Network Isolation | Disable public access, use private endpoints |

### Secrets Management

- **Never** store secrets in Terraform code or tfvars files
- Use Key Vault references for secrets
- Use Terraform data sources to read secrets from Key Vault
- Enable managed identity for applications to access Key Vault

```hcl
data "azurerm_key_vault_secret" "example" {
  name         = "secret-name"
  key_vault_id = var.key_vault_id
}
```
