variable "managed_clusters" {
  type = map(object({
    # Required
    parent_id = string # Resource Group ID where AKS will be created

    # Optional - Basic Configuration
    name             = optional(string)
    location         = optional(string)
    enable_telemetry = optional(bool, false)
    dns_prefix       = optional(string)
    fqdn_subdomain   = optional(string)

    # Kubernetes Version
    kubernetes_version = optional(string) # null = latest stable

    # SKU Configuration
    sku = optional(object({
      name = optional(string, "Base")
      tier = optional(string, "Free") # "Free" for dev, "Standard" for production SLA
    }))

    # Kind
    kind = optional(string)

    # Support Plan
    support_plan = optional(string)

    # Auto-upgrade Profile
    auto_upgrade_profile = optional(object({
      upgrade_channel = optional(string, "patch") # "patch", "rapid", "stable", "node-image", "none"
    }))

    # Upgrade Settings
    upgrade_settings = optional(object({
      overrides = optional(any)
    }))

    # Node Resource Group
    node_resource_group = optional(string)
    node_resource_group_profile = optional(object({
      restricted_mode = optional(bool, true)
    }))

    # Default Agent Pool
    default_agent_pool = optional(object({
      name                         = optional(string, "system")
      vm_size                      = optional(string, "Standard_D2s_v3") # Cost-efficient default
      node_count                   = optional(number, 1)
      only_critical_addons_enabled = optional(bool, true) # System pool for system pods only
      temporary_name_for_rotation  = optional(string, "temp")
      auto_scaling_enabled         = optional(bool, true)
      min_count                    = optional(number, 1)
      max_count                    = optional(number, 3)
      os_sku                       = optional(string, "AzureLinux") # More secure than Ubuntu
      os_disk_size_gb              = optional(number)
      os_disk_type                 = optional(string, "Managed")
      ultra_ssd_enabled            = optional(bool, false)
      zones                        = optional(list(string), ["1", "2", "3"]) # Zone-redundant
      max_pods                     = optional(number, 30)
      node_labels                  = optional(map(string))
      node_taints                  = optional(list(string))
      vnet_subnet_id               = optional(string)
      pod_subnet_id                = optional(string)
      enable_host_encryption       = optional(bool, true) # Secure default
      fips_enabled                 = optional(bool, false)
      kubelet_disk_type            = optional(string)
      orchestrator_version         = optional(string)
      proximity_placement_group_id = optional(string)
      scale_down_mode              = optional(string, "Delete")
      snapshot_id                  = optional(string)
      workload_runtime             = optional(string)
      upgrade_settings = optional(object({
        max_surge = optional(string, "10%")
      }))
      kubelet_config  = optional(any)
      linux_os_config = optional(any)
    }))

    # Network Profile
    network_profile = optional(object({
      network_plugin      = optional(string, "azure")
      network_policy      = optional(string, "azure")        # Enable network policies by default
      network_plugin_mode = optional(string, "overlay")      # Overlay mode for better IP management
      outbound_type       = optional(string, "loadBalancer") # Controlled egress
      load_balancer_sku   = optional(string, "standard")
      service_cidr        = optional(string, "10.0.0.0/16")
      dns_service_ip      = optional(string, "10.0.0.10")
      pod_cidr            = optional(string)
      network_data_plane  = optional(string)
      load_balancer_profile = optional(object({
        managed_outbound_ip_count   = optional(number)
        outbound_ip_address_ids     = optional(list(string))
        outbound_ip_prefix_ids      = optional(list(string))
        outbound_ports_allocated    = optional(number)
        idle_timeout_in_minutes     = optional(number)
        managed_outbound_ipv6_count = optional(number)
      }))
      nat_gateway_profile = optional(object({
        managed_outbound_ip_count = optional(number)
        idle_timeout_in_minutes   = optional(number)
      }))
    }))

    # API Server Access Profile
    api_server_access_profile = optional(object({
      authorized_ip_ranges = optional(list(string))
    }))

    # Managed Identity - Secure default enables system-assigned
    managed_identities = optional(object({
      system_assigned            = optional(bool, true)
      user_assigned_resource_ids = optional(set(string))
    }))

    # Azure AD Profile - Secure defaults
    aad_profile = optional(object({
      azure_rbac_enabled     = optional(bool, true)
      managed                = optional(bool, true)
      admin_group_object_ids = optional(list(string), [])
      tenant_id              = optional(string)
    }))

    # Disable Local Accounts - Secure default (RBAC only)
    disable_local_accounts = optional(bool, true)

    # Enable RBAC
    enable_rbac = optional(bool, true)

    # Security Profile
    security_profile = optional(object({
      defender = optional(object({
        log_analytics_workspace_resource_id = string
      }))
      workload_identity_enabled = optional(bool, true)
      image_cleaner = optional(object({
        enabled        = optional(bool, true)
        interval_hours = optional(number, 48)
      }))
    }))

    # Azure Policy Addon - Secure default (enabled)
    addon_profile_azure_policy = optional(object({
      enabled = optional(bool, true)
    }))

    # Key Vault Secrets Provider - Secure default with rotation
    addon_profile_key_vault_secrets_provider = optional(object({
      enabled                  = optional(bool, true)
      secret_rotation_enabled  = optional(bool, true)
      secret_rotation_interval = optional(string, "2m")
    }))

    # OIDC Issuer Profile - Secure default for workload identity
    oidc_issuer_profile = optional(object({
      enabled = optional(bool, true)
    }))

    # OMS Agent (Container Insights)
    addon_profile_oms_agent = optional(object({
      enabled                    = optional(bool, true)
      log_analytics_workspace_id = string
    }))

    # Ingress Application Gateway
    addon_profile_ingress_application_gateway = optional(object({
      enabled    = optional(bool, true)
      gateway_id = optional(string)
      subnet_id  = optional(string)
    }))

    # Confidential Computing
    addon_profile_confidential_computing = optional(any)

    # Extra Addon Profiles
    addon_profiles_extra = optional(any)

    # Azure Monitor Profile
    azure_monitor_profile = optional(object({
      metrics = optional(object({
        enabled                        = optional(bool, true)
        annotations_allowed            = optional(string)
        labels_allowed                 = optional(string)
        kube_state_metrics_annotations = optional(string)
        kube_state_metrics_labels      = optional(string)
      }))
    }))

    # Metrics Profile
    metrics_profile = optional(any)

    # Public Network Access
    public_network_access = optional(string)

    # Private Endpoints
    private_endpoints = optional(map(object({
      name                            = optional(string)
      subnet_resource_id              = string
      private_dns_zone_group_name     = optional(string, "default")
      private_dns_zone_resource_ids   = optional(set(string))
      private_service_connection_name = optional(string)
      network_interface_name          = optional(string)
      location                        = optional(string)
      resource_group_name             = optional(string)
      ip_configurations = optional(map(object({
        name               = string
        private_ip_address = optional(string)
      })), {})
      tags = optional(map(string))
      lock = optional(object({
        kind = string
        name = optional(string)
      }))
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        description                            = optional(string)
        skip_service_principal_aad_check       = optional(bool, false)
        condition                              = optional(string)
        condition_version                      = optional(string)
        delegated_managed_identity_resource_id = optional(string)
        principal_type                         = optional(string)
      })))
    })), {})
    private_endpoints_manage_dns_zone_group = optional(bool, true)

    # Private Link Resources
    private_link_resources = optional(any)

    # Disk Encryption
    disk_encryption_set_id = optional(string)

    # HTTP Proxy
    http_proxy_config = optional(object({
      http_proxy  = optional(string)
      https_proxy = optional(string)
      no_proxy    = optional(list(string))
      trusted_ca  = optional(string)
    }))

    # Ingress Profile
    ingress_profile = optional(object({
      web_app_routing = optional(object({
        dns_zone_resource_id = optional(string)
      }))
    }))

    # Identity Profile
    identity_profile = optional(any)

    # Linux Profile
    linux_profile = optional(object({
      admin_username = string
      ssh_key = object({
        key_data = string
      })
    }))

    # Windows Profile
    windows_profile = optional(object({
      admin_username = string
      license        = optional(string)
    }))
    windows_profile_password = optional(string)

    # Service Mesh (Istio)
    service_mesh_profile = optional(object({
      mode                             = string # "Istio"
      external_ingress_gateway_enabled = optional(bool, false)
      internal_ingress_gateway_enabled = optional(bool, false)
    }))

    # Storage Profile
    storage_profile = optional(object({
      blob_driver_enabled         = optional(bool, false)
      disk_driver_enabled         = optional(bool, true)
      file_driver_enabled         = optional(bool, true)
      snapshot_controller_enabled = optional(bool, true)
    }))

    # Auto-scaler Profile
    auto_scaler_profile = optional(object({
      balance_similar_node_groups      = optional(bool, false)
      empty_bulk_delete_max            = optional(number, 10)
      expander                         = optional(string, "random")
      max_graceful_termination_sec     = optional(number, 600)
      max_node_provisioning_time       = optional(string, "15m")
      max_unready_nodes                = optional(number, 3)
      max_unready_percentage           = optional(number, 45)
      new_pod_scale_up_delay           = optional(string, "10s")
      scale_down_delay_after_add       = optional(string, "10m")
      scale_down_delay_after_delete    = optional(string, "10s")
      scale_down_delay_after_failure   = optional(string, "3m")
      scale_down_unneeded              = optional(string, "10m")
      scale_down_unready               = optional(string, "20m")
      scale_down_utilization_threshold = optional(number, 0.5)
      scan_interval                    = optional(string, "10s")
      skip_nodes_with_local_storage    = optional(bool, true)
      skip_nodes_with_system_pods      = optional(bool, true)
    }))

    # Workload Auto-scaler (KEDA/VPA)
    workload_auto_scaler_profile = optional(object({
      keda_enabled                    = optional(bool, false)
      vertical_pod_autoscaler_enabled = optional(bool, false)
    }))

    # Node Provisioning Profile
    node_provisioning_profile = optional(any)

    # Pod Identity Profile
    pod_identity_profile = optional(object({
      enabled                      = optional(bool, false)
      allow_network_plugin_kubenet = optional(bool, false)
    }))

    # Bootstrap Profile
    bootstrap_profile = optional(any)

    # Service Principal Profile
    service_principal_profile = optional(any)

    # AI Toolchain Operator Profile
    ai_toolchain_operator_profile = optional(any)

    # Extended Location
    extended_location = optional(any)

    # Agent Pool Lifecycle
    create_agentpools_before_destroy = optional(bool)

    # Timeouts
    cluster_timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
    agentpool_timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))

    # Resource Lock
    lock = optional(object({
      kind = string # "CanNotDelete" or "ReadOnly"
      name = optional(string)
    }))

    # Role Assignments
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string)
      condition_version                      = optional(string)
      delegated_managed_identity_resource_id = optional(string)
      principal_type                         = optional(string)
    })))

    # Diagnostic Settings
    diagnostic_settings = optional(map(object({
      name                                     = optional(string)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string)
      storage_account_resource_id              = optional(string)
      event_hub_authorization_rule_resource_id = optional(string)
      event_hub_name                           = optional(string)
      marketplace_partner_resource_id          = optional(string)
    })))

    # Tags
    tags = optional(map(string))
  }))
  default     = {}
  description = "Map of Azure Kubernetes Service clusters to create with all AVM module options exposed"
}

variable "location_short" {
  type        = string
  description = "Short location identifier (e.g., 'eus', 'wus', 'cus')"
}

variable "environment" {
  type        = string
  description = "Environment identifier (e.g., 'dev', 'staging', 'prod')"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created (e.g., 'eastus', 'westus')"
}

variable "project_name" {
  type        = string
  description = "Project name used for resource naming"
}
