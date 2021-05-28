output "kube_config" {
  value = azurerm_kubernetes_cluster.this.kube_config
}

output "postgresql_fqdn" {
  value = trimsuffix(azurerm_postgresql_server.this.fqdn, ".")
}

output "az_pg_server" {
  value = azurerm_postgresql_server.this.name
}
