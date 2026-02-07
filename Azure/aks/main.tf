locals {
  suffix = join("-", compact([
    var.project_name, var.environment, var.location_short
  ]))

  names = {
    aks = "aks-${local.suffix}"
  }

  tags = {
    project     = var.project_name
    environment = var.environment
    location    = var.location
  }
}

module "managed_clusters" {
  source  = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version = "~> 0.4"

  for_each = var.managed_clusters

  # Required
  name      = coalesce(try(each.value.name, null), "${local.names.aks}-${each.key}")
  location  = coalesce(try(each.value.location, null), var.location)
  parent_id = each.value.parent_id

  # Optional - Telemetry
  enable_telemetry = coalesce(try(each.value.enable_telemetry, null), false)

  # Kubernetes Version
  kubernetes_version = try(each.value.kubernetes_version, null)

  # DNS Prefix
  dns_prefix     = try(each.value.dns_prefix, null)
  fqdn_subdomain = try(each.value.fqdn_subdomain, null)

  # SKU Configuration - Cost-efficient default
  sku = try(each.value.sku, {
    name = "Base"
    tier = "Free"
  })

  # Kind
  kind = try(each.value.kind, null)

  # Support Plan
  support_plan = try(each.value.support_plan, null)

  # Auto-upgrade Profile - Secure default (patch channel)
  auto_upgrade_profile = try(each.value.auto_upgrade_profile, {
    upgrade_channel = "patch"
  })

  # Upgrade Settings
  upgrade_settings = try(each.value.upgrade_settings, null)

  # Node Resource Group
  node_resource_group         = try(each.value.node_resource_group, null)
  node_resource_group_profile = try(each.value.node_resource_group_profile, null)

  # Default Agent Pool - Secure and cost-conscious defaults merged with user overrides
  default_agent_pool = merge({
    name                         = "system"
    vm_size                      = "Standard_D2s_v3"
    node_count                   = 1
    only_critical_addons_enabled = true
    temporary_name_for_rotation  = "temp"
    auto_scaling_enabled         = true
    min_count                    = 1
    max_count                    = 3
    os_sku                       = "AzureLinux"
    zones                        = ["1", "2", "3"]
  }, try(each.value.default_agent_pool, {}))

  # Network Profile - Secure defaults if not provided
  network_profile = try(each.value.network_profile, null) != null ? each.value.network_profile : {
    network_plugin      = "azure"
    network_policy      = "azure"
    network_plugin_mode = "overlay"
    outbound_type       = "loadBalancer"
    load_balancer_sku   = "standard"
    service_cidr        = "10.0.0.0/16"
    dns_service_ip      = "10.0.0.10"
  }

  # API Server Access Profile
  api_server_access_profile = try(each.value.api_server_access_profile, null)

  # Managed Identity - Secure default (system-assigned)
  managed_identities = try(each.value.managed_identities, {
    system_assigned = true
  })

  # Azure AD Profile - Secure defaults (managed AAD with Azure RBAC)
  aad_profile = try(each.value.aad_profile, {
    azure_rbac_enabled = true
    managed            = true
  })

  # Disable Local Accounts - Secure default (RBAC only)
  disable_local_accounts = coalesce(try(each.value.disable_local_accounts, null), true)

  # Enable RBAC
  enable_rbac = coalesce(try(each.value.enable_rbac, null), true)

  # Security Profile
  security_profile = try(each.value.security_profile, null)

  # Azure Policy Addon - Secure default (enabled)
  addon_profile_azure_policy = try(each.value.addon_profile_azure_policy, {
    enabled = true
  })

  # Key Vault Secrets Provider - Secure default with rotation
  addon_profile_key_vault_secrets_provider = try(each.value.addon_profile_key_vault_secrets_provider, {
    enabled                  = true
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  })

  # OIDC Issuer Profile - Secure default for workload identity
  oidc_issuer_profile = try(each.value.oidc_issuer_profile, {
    enabled = true
  })

  # OMS Agent (Container Insights)
  addon_profile_oms_agent = try(each.value.addon_profile_oms_agent, null)

  # Ingress Application Gateway
  addon_profile_ingress_application_gateway = try(each.value.addon_profile_ingress_application_gateway, null)

  # Confidential Computing
  addon_profile_confidential_computing = try(each.value.addon_profile_confidential_computing, null)

  # Extra Addon Profiles
  addon_profiles_extra = try(each.value.addon_profiles_extra, null)

  # Azure Monitor Profile
  azure_monitor_profile = try(each.value.azure_monitor_profile, null)

  # Metrics Profile
  metrics_profile = try(each.value.metrics_profile, null)

  # Public Network Access
  public_network_access = try(each.value.public_network_access, null)

  # Private Endpoints
  private_endpoints                       = try(each.value.private_endpoints, {})
  private_endpoints_manage_dns_zone_group = try(each.value.private_endpoints_manage_dns_zone_group, true)

  # Private Link Resources
  private_link_resources = try(each.value.private_link_resources, null)

  # Disk Encryption
  disk_encryption_set_id = try(each.value.disk_encryption_set_id, null)

  # HTTP Proxy
  http_proxy_config = try(each.value.http_proxy_config, null)

  # Ingress Profile
  ingress_profile = try(each.value.ingress_profile, null)

  # Identity Profile
  identity_profile = try(each.value.identity_profile, null)

  # Linux Profile
  linux_profile = try(each.value.linux_profile, null)

  # Windows Profile
  windows_profile          = try(each.value.windows_profile, null)
  windows_profile_password = try(each.value.windows_profile_password, null)

  # Service Mesh (Istio)
  service_mesh_profile = try(each.value.service_mesh_profile, null)

  # Storage Profile
  storage_profile = try(each.value.storage_profile, null)

  # Auto-scaler Profile
  auto_scaler_profile = try(each.value.auto_scaler_profile, null)

  # Workload Auto-scaler (KEDA/VPA)
  workload_auto_scaler_profile = try(each.value.workload_auto_scaler_profile, null)

  # Node Provisioning Profile
  node_provisioning_profile = try(each.value.node_provisioning_profile, null)

  # Pod Identity Profile
  pod_identity_profile = try(each.value.pod_identity_profile, null)

  # Bootstrap Profile
  bootstrap_profile = try(each.value.bootstrap_profile, null)

  # Service Principal Profile
  service_principal_profile = try(each.value.service_principal_profile, null)

  # AI Toolchain Operator Profile
  ai_toolchain_operator_profile = try(each.value.ai_toolchain_operator_profile, null)

  # Extended Location
  extended_location = try(each.value.extended_location, null)

  # Agent Pool Lifecycle
  create_agentpools_before_destroy = try(each.value.create_agentpools_before_destroy, null)

  # Timeouts
  cluster_timeouts   = try(each.value.cluster_timeouts, null)
  agentpool_timeouts = try(each.value.agentpool_timeouts, null)

  # Resource Lock
  lock = try(each.value.lock, null)

  # Role Assignments
  role_assignments = try(each.value.role_assignments, {})

  # Diagnostic Settings
  diagnostic_settings = try(each.value.diagnostic_settings, {})

  # Tags
  tags = merge(local.tags, try(each.value.tags, {}))
}
