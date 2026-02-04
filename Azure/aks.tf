module "aks_foundation" {
  source  = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version = "0.4.2"

  for_each = var.aks_foundation

  # Required
  name      = coalesce(try(each.value.name, null), "${local.names.aks}-${each.key}")
  location  = coalesce(try(each.value.location, null), var.location)
  parent_id = module.rg_foundation[each.value.rg_key].resource_id

  # Optional - Telemetry
  enable_telemetry = coalesce(try(each.value.enable_telemetry, null), false)

  # Kubernetes Version
  kubernetes_version = try(each.value.kubernetes_version, null)

  # DNS Prefix
  dns_prefix = try(each.value.dns_prefix, null)

  # SKU Configuration
  sku = try(each.value.sku, {
    name = "Base"
    tier = "Free" # Cost-efficient default; use "Standard" for production SLA
  })

  # Auto-upgrade Profile
  auto_upgrade_profile = try(each.value.auto_upgrade_profile, {
    upgrade_channel = "patch" # Secure default - automatic security patches
  })

  # Node Resource Group
  node_resource_group         = try(each.value.node_resource_group, null)
  node_resource_group_profile = try(each.value.node_resource_group_profile, null)

  # Default Agent Pool
  default_agent_pool = merge({
    name                         = "system"
    vm_size                      = "Standard_D2s_v3" # Cost-efficient default
    node_count                   = 1
    only_critical_addons_enabled = true # Secure default - only system pods on system pool
    temporary_name_for_rotation  = "temp"
    auto_scaling_enabled         = true
    min_count                    = 1
    max_count                    = 3
    os_sku                       = "AzureLinux" # Secure default - AzureLinux is more secure
    zones                        = ["1", "2", "3"]
    }, try(each.value.default_agent_pool, {}), {
    # Handle subnet key references
    vnet_subnet_id = try(each.value.default_agent_pool.vnet_subnet_id, null) != null ? each.value.default_agent_pool.vnet_subnet_id : (
      try(each.value.default_agent_pool.subnet_key, null) != null ? module.vnet_foundation[each.value.default_agent_pool.vnet_key].subnets[each.value.default_agent_pool.subnet_key].resource_id : null
    )
  })

  # Network Profile - Secure defaults
  network_profile = try(each.value.network_profile, null) != null ? each.value.network_profile : {
    network_plugin      = "azure"
    network_policy      = "azure"        # Secure default - enable network policies
    network_plugin_mode = "overlay"      # Recommended for scalability
    outbound_type       = "loadBalancer" # Secure default - controlled egress
    load_balancer_sku   = "standard"
    service_cidr        = "10.0.0.0/16"
    dns_service_ip      = "10.0.0.10"
  }

  # API Server Access Profile - Secure defaults
  api_server_access_profile = try(each.value.api_server_access_profile, null)

  # Managed Identity - Secure default
  managed_identities = try(each.value.managed_identities, {
    system_assigned = true # Secure default - use managed identity
  })

  # Azure AD Profile - Secure defaults
  aad_profile = try(each.value.aad_profile, {
    azure_rbac_enabled = true # Secure default - use Azure RBAC
    managed            = true # Secure default - use managed Azure AD integration
  })

  # Disable Local Accounts - Secure default
  disable_local_accounts = try(each.value.disable_local_accounts, true) # Secure default

  # Enable RBAC
  enable_rbac = try(each.value.enable_rbac, true) # Secure default

  # Security Profile - Secure defaults
  security_profile = try(each.value.security_profile, null)

  # Azure Policy Addon - Secure default
  addon_profile_azure_policy = try(each.value.addon_profile_azure_policy, {
    enabled = true # Secure default - enable Azure Policy
  })

  # Azure Monitor Profile
  azure_monitor_profile = try(each.value.azure_monitor_profile, null)

  # OMS Agent (Container Insights)
  addon_profile_oms_agent = try(each.value.addon_profile_oms_agent, null) != null ? each.value.addon_profile_oms_agent : (
    try(each.value.log_analytics_workspace_resource_id, null) != null ? {
      enabled                    = true
      log_analytics_workspace_id = each.value.log_analytics_workspace_resource_id
    } : null
  )

  # Key Vault Secrets Provider
  addon_profile_key_vault_secrets_provider = try(each.value.addon_profile_key_vault_secrets_provider, {
    enabled                  = true
    secret_rotation_enabled  = true # Secure default - rotate secrets
    secret_rotation_interval = "2m"
  })

  # OIDC Issuer Profile - Required for workload identity
  oidc_issuer_profile = try(each.value.oidc_issuer_profile, {
    enabled = true # Secure default for workload identity
  })

  # Public Network Access
  public_network_access = try(each.value.public_network_access, "Enabled")

  # Private Endpoints
  private_endpoints                       = try(each.value.private_endpoints, {})
  private_endpoints_manage_dns_zone_group = try(each.value.private_endpoints_manage_dns_zone_group, true)

  # Disk Encryption
  disk_encryption_set_id = try(each.value.disk_encryption_set_id, null)

  # HTTP Proxy
  http_proxy_config = try(each.value.http_proxy_config, null)

  # Ingress Profile
  ingress_profile = try(each.value.ingress_profile, null)

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

  # Workload Auto-scaler Profile (KEDA/VPA)
  workload_auto_scaler_profile = try(each.value.workload_auto_scaler_profile, null)

  # Pod Identity Profile
  pod_identity_profile = try(each.value.pod_identity_profile, null)

  # Resource Lock
  lock = try(each.value.lock, null)

  # Role Assignments
  role_assignments = try(each.value.role_assignments, {})

  # Diagnostic Settings
  diagnostic_settings = try(each.value.diagnostic_settings, {})

  # Tags
  tags = merge(local.tags, try(each.value.tags, {}))
}
