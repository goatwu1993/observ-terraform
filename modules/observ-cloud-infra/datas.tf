data "azurerm_resource_group" "this" {
  name = var.rg_name
}

data "http" "my_public_ip" {
  url = "https://api.ipify.org?format=json"
  request_headers = {
    Accept = "application/json"
  }
}
