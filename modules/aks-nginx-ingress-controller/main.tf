resource "azurerm_public_ip" "this" {
  name                = var.aks_public_ip_name
  resource_group_name = data.azurerm_resource_group.aks_node.name
  domain_name_label   = data.azurerm_kubernetes_cluster.this.dns_prefix
  location            = data.azurerm_resource_group.aks_node.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }

  # Error occurs if terraform try to delete public ip before helm fully destroyed because public ip is already attached.
  # Remove if helm uninstall can -wait.
  depends_on = [
    azurerm_public_ip.this
  ]
}

resource "helm_release" "this" {
  name       = var.helm_release_name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.this.metadata[0].name

  set {
    name  = "controller.replicaCount"
    value = var.controller_replica_count
  }

  set {
    name  = "controller.nodeSelector\\.beta\\.kubernetes\\.io/os'"
    value = "linux"
  }
  set {
    name  = "defaultBackend.nodeSelector\\.beta\\.kubernetes\\.io/os'"
    value = "linux"
  }
  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.this.ip_address
  }

  set {
    name  = "controller.service.annotations\\.service\\.beta\\.kubernetes\\.io/azure-dns-label-name'"
    value = azurerm_public_ip.this.domain_name_label
  }
}
