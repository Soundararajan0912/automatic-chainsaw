output "id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.name
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kubelet_identity" {
  description = "Kubelet identity object"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity
}

output "node_resource_group" {
  description = "The auto-generated resource group for the AKS cluster nodes"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}
