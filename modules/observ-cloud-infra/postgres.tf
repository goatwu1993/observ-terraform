resource "azurerm_postgresql_server" "this" {
  name                = var.pg_server_name
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  administrator_login          = var.pg_admin_login
  administrator_login_password = var.pg_admin_login_password

  sku_name   = var.pg_sku_name
  version    = var.pg_version
  storage_mb = var.pg_storage_mb

  backup_retention_days        = 7
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = true

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
  tags                             = var.tags
}

resource "azurerm_postgresql_virtual_network_rule" "this" {
  name                                 = "allow-aks"
  resource_group_name                  = azurerm_postgresql_server.this.resource_group_name
  server_name                          = azurerm_postgresql_server.this.name
  subnet_id                            = azurerm_subnet.aks_pods_subnet.id
  ignore_missing_vnet_service_endpoint = true
}

resource "azurerm_postgresql_firewall_rule" "this" {
  name                = "terraform-client-local-ip"
  resource_group_name = azurerm_postgresql_server.this.resource_group_name
  server_name         = azurerm_postgresql_server.this.name
  start_ip_address    = jsondecode(data.http.my_public_ip.body).ip
  end_ip_address      = jsondecode(data.http.my_public_ip.body).ip
}
