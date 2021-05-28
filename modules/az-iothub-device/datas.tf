data "azurerm_resource_group" "this" {
  name = var.iothub_rg
}

data "azurerm_iothub" "this" {
  name                = var.iothub_name
  resource_group_name = var.iothub_rg
}
