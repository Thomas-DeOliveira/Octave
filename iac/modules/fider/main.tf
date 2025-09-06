data "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-prod-octave"
  resource_group_name = "rg-octave-prod"
}

data "azurerm_client_config" "current" {}

# KV existant
data "azurerm_key_vault" "kv" {
  name                = "keyvault-fider"
  resource_group_name = "rg-octave-prod"
  # ⚠️ Ce KV doit être en RBAC (enable_rbac_authorization = true) pour que le role assignment marche
}

# App Registration (AAD / Entra)
resource "azuread_application" "fider_app" {
  display_name = "fider-workload-identity"
}

# Service Principal lié à l'app
resource "azuread_service_principal" "fider_sp" {
  client_id = azuread_application.fider_app.client_id
}

# Federated Credential (liaison AKS OIDC -> App)
resource "azuread_application_federated_identity_credential" "fider_fic" {
  application_id = azuread_application.fider_app.id
  display_name   = "fider-federated-credential"
  issuer         = data.azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject        = "system:serviceaccount:fider:fider-sa"
  audiences      = ["api://AzureADTokenExchange"]
}


# Attribution du rôle Key Vault Secrets User au SP sur le KV (RBAC required)
resource "azurerm_role_assignment" "fider_kv_rbac" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_service_principal.fider_sp.object_id
  depends_on           = [azuread_service_principal.fider_sp]
}
