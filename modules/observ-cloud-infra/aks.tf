resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  address_space       = ["10.0.0.0/8"]
  tags                = var.tags
}

resource "azurerm_subnet" "aks_pods_subnet" {
  name                                          = "aks-cloud-pods-subnet"
  resource_group_name                           = data.azurerm_resource_group.this.name
  virtual_network_name                          = azurerm_virtual_network.aks_vnet.name
  address_prefixes                              = ["10.240.0.0/16"]
  enforce_private_link_service_network_policies = true
  service_endpoints                             = ["Microsoft.Sql", "Microsoft.ServiceBus", "Microsoft.EventHub"]
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.aks_name
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  dns_prefix          = var.aks_dns_prefix

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = var.aks_vm_size
    vnet_subnet_id = azurerm_subnet.aks_pods_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}
