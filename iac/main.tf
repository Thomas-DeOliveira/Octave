data "azurerm_resource_group" "rg" {
  name = "rg-octave-prod"
}

data "azurerm_client_config" "current" {}

module "network" {
  source                = "./modules/network"
  resource_group_name   = data.azurerm_resource_group.rg.name
  location              = data.azurerm_resource_group.rg.location
}

module "aks" {
  source                = "./modules/aks"
  resource_group_name   = data.azurerm_resource_group.rg.name
  location              = data.azurerm_resource_group.rg.location
  subnet_id             = module.network.subnet_id
}

module "keyvault" {
  source                = "./modules/keyvault"
  resource_group_name   = data.azurerm_resource_group.rg.name
  location              = data.azurerm_resource_group.rg.location
  tenant_id             = data.azurerm_client_config.current.tenant_id
  object_id             = data.azurerm_client_config.current.object_id
  aks_mi_principal_id = module.aks.aks_mi_principal_id
}

module "fider" {
  source                = "./modules/fider"
  resource_group_name   = data.azurerm_resource_group.rg.name
}
