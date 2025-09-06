data "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-prod-octave"
  resource_group_name = "rg-octave-prod"
}

data "azurerm_client_config" "current" {}

# KV existant (en mode RBAC)
data "azurerm_key_vault" "kv" {
  name                = "keyvault-fider"
  resource_group_name = "rg-octave-prod"
}

# App Registration (Entra ID)
resource "azuread_application" "fider_app" {
  display_name = "fider-workload-identity"
}

# Service Principal lié à l'app
resource "azuread_service_principal" "fider_sp" {
  client_id = azuread_application.fider_app.client_id
}

# === Ajout: plusieurs ServiceAccounts avec la même App ===
locals {
  namespace        = "fider-prod"
  service_accounts = ["fider-sa", "postgres-sa"]
}

# Une Federated Identity Credential par SA
resource "azuread_application_federated_identity_credential" "fic" {
  for_each       = toset(local.service_accounts)
  application_id = azuread_application.fider_app.id
  display_name   = "fic-${each.value}"
  issuer         = data.azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject        = "system:serviceaccount:${local.namespace}:${each.value}"
  audiences      = ["api://AzureADTokenExchange"]
}

# Rôle Key Vault Secrets User pour le SP sur le KV
resource "azurerm_role_assignment" "fider_kv_rbac" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_service_principal.fider_sp.object_id
  depends_on           = [azuread_service_principal.fider_sp]
}

# (Optionnel) sorties utiles
output "workload_client_id" {
  value = azuread_application.fider_app.client_id
}

output "workload_sp_object_id" {
  value = azuread_service_principal.fider_sp.object_id
}
