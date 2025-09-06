output "fider_app_client_id" {
  description = "Client ID de l'App Registration Fider"
  value       = azuread_application.fider_app.client_id
}

output "fider_app_object_id" {
  description = "Object ID de l'App Registration Fider"
  value       = azuread_application.fider_app.object_id
}

output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}

output "aks_oidc_issuer_url" {
  value = data.azurerm_kubernetes_cluster.aks.oidc_issuer_url
}
