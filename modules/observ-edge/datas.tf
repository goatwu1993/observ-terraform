data "azurerm_resource_group" "this" {
  name = var.ams_account_rg
}

data "azurerm_storage_account" "this" {
  name                = var.ams_storage_account_name
  resource_group_name = var.ams_storage_account_rg
}

data "azurerm_client_config" "current" {
}
