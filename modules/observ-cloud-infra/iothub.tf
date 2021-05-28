resource "azurerm_iothub" "this" {
  name                = var.iothub_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  tags = var.tags
}
