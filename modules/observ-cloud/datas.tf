data "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = var.storage_account_rg
}

data "azurerm_iothub" "this" {
  name                = var.iothub_name
  resource_group_name = var.iothub_rg
}

data "azurerm_iothub_shared_access_policy" "this" {
  name                = "iothubowner"
  resource_group_name = data.azurerm_iothub.this.resource_group_name
  iothub_name         = data.azurerm_iothub.this.name
}

data "azurerm_postgresql_server" "this" {
  name                = var.az_pg_server
  resource_group_name = var.az_pg_server_rg
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

data "azurerm_eventhub_consumer_group" "this" {
  name                = var.eventhub_consumer_group
  namespace_name      = data.azurerm_eventhub_namespace.this.name
  eventhub_name       = data.azurerm_eventhub.this.name
  resource_group_name = data.azurerm_eventhub_namespace.this.resource_group_name
}

data "azurerm_eventhub_authorization_rule" "this" {
  name                = var.eventhub_authorization_rule
  namespace_name      = data.azurerm_eventhub_namespace.this.name
  eventhub_name       = data.azurerm_eventhub.this.name
  resource_group_name = data.azurerm_eventhub_namespace.this.resource_group_name
}

data "http" "my_public_ip" {
  url = "https://api.ipify.org?format=json"
  request_headers = {
    Accept = "application/json"
  }
}
