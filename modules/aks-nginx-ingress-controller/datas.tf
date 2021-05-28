data "azurerm_kubernetes_cluster" "this" {
  name                = var.aks_name
  resource_group_name = var.aks_rg
}

data "azurerm_resource_group" "aks_node" {
  name = data.azurerm_kubernetes_cluster.this.node_resource_group
}
