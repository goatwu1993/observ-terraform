data "azurerm_resource_group" "this" {
  name = var.ams_account_rg
}

data "azurerm_storage_account" "this" {
  name                = var.ams_storage_account_name
  resource_group_name = var.ams_storage_account_rg
}

data "azurerm_client_config" "current" {
}

data "azurerm_eventhub_namespace" "this" {
  name                = var.eventhub_namespace
  resource_group_name = var.eventhub_namespace_rg
}

data "azurerm_eventhub" "this" {
  name                = var.eventhub
  namespace_name      = data.azurerm_eventhub_namespace.this.name
  resource_group_name = data.azurerm_eventhub_namespace.this.resource_group_name
}

data "azurerm_eventhub_authorization_rule" "this" {
  name                = var.eventhub_authorization_rule
  namespace_name      = data.azurerm_eventhub_namespace.this.name
  eventhub_name       = data.azurerm_eventhub.this.name
  resource_group_name = data.azurerm_eventhub_namespace.this.resource_group_name
}
