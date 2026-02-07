output "managed_clusters" {
  description = "Map of created AKS managed clusters with all attributes"
  value       = module.managed_clusters
  sensitive   = true
}

output "aks_ids" {
  description = "Map of AKS cluster resource IDs"
  value       = { for k, v in module.managed_clusters : k => v.resource_id }
}

output "aks_names" {
  description = "Map of AKS cluster names"
  value       = { for k, v in module.managed_clusters : k => v.name }
}

output "aks_fqdns" {
  description = "Map of AKS cluster FQDNs"
  value       = { for k, v in module.managed_clusters : k => v.fqdn }
}

output "aks_principal_ids" {
  description = "Map of AKS cluster system-assigned managed identity principal IDs"
  value       = { for k, v in module.managed_clusters : k => v.identity_principal_id }
}

output "aks_oidc_issuer_urls" {
  description = "Map of AKS OIDC issuer profile URLs for workload identity federation"
  value       = { for k, v in module.managed_clusters : k => v.oidc_issuer_profile_issuer_url }
}
