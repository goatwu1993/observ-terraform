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

data "http" "my_public_ip" {
  url = "https://api.ipify.org?format=json"
  request_headers = {
    Accept = "application/json"
  }
}
