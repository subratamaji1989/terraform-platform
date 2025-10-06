# outputs.tf - Outputs from the AKS module

output "cluster_id" {
  description = "The ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "The name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.aks.name
}

output "kube_config_raw" {
  description = "The raw Kubernetes configuration for the cluster. Can be used to connect with kubectl."
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}