output "aks_mi_principal_id" {
  description = "The principal ID of the AKS managed identity"
  value       = azurerm_user_assigned_identity.aks_mi.principal_id
}
output "name" {
  value = azurerm_kubernetes_cluster.k8s.name
}