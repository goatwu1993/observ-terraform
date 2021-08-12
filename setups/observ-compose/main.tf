resource "azurerm_resource_group" "this" {
  name     = local.rg_name
  location = var.rg_location
  tags     = var.tags
}

resource "azurerm_storage_account" "this" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  allow_blob_public_access = true

  tags = var.tags
}

resource "azurerm_eventhub_namespace" "this" {
  name                = local.eventhub_namespace
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"
  capacity            = 2

  tags = var.tags
}

resource "azurerm_eventhub" "this" {
  name                = local.eventhub
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = azurerm_eventhub_namespace.this.resource_group_name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_consumer_group" "this" {
  name                = local.eventhub_consumer_group
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.this.name
  resource_group_name = azurerm_eventhub_namespace.this.resource_group_name
  user_metadata       = "observ-terraform"
}

resource "azurerm_eventhub_authorization_rule" "this" {
  name                = local.eventhub_authorization_rule
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.this.name
  resource_group_name = azurerm_eventhub_namespace.this.resource_group_name
  listen              = true
  send                = true
  manage              = false
}
module "observ_cloud_infra" {
  source                  = "./../../modules/observ-cloud-infra/"
  rg_name                 = azurerm_resource_group.this.name
  aks_name                = local.aks_cloud_name
  aks_vm_size             = var.aks_cloud_vm_size
  aks_dns_prefix          = local.aks_cloud_dns_prefix
  iothub_name             = local.iothub_name
  iothub_rg               = azurerm_resource_group.this.name
  pg_server_name          = local.pg_server_name
  pg_admin_login          = var.pg_admin_login
  pg_admin_login_password = var.pg_admin_login_password
  pg_sku_name             = var.pg_sku_name
  pg_version              = var.pg_version
  pg_storage_mb           = var.pg_storage_mb
  tags                    = var.tags

  depends_on = [
    azurerm_resource_group.this
  ]
}

module "observ_cloud_ingress_controller" {
  source             = "./../../modules/aks-nginx-ingress-controller/"
  aks_name           = local.aks_cloud_name
  aks_rg             = azurerm_resource_group.this.name
  aks_public_ip_name = local.aks_cloud_public_ip_name
  tags               = var.tags

  depends_on = [
    module.observ_cloud_infra
  ]
}

module "observ_cloud" {
  source = "./../../modules/observ-cloud/"

  suffix    = var.suffix
  image_tag = var.image_tag
  # DNS
  dns = trimsuffix(module.observ_cloud_ingress_controller.fqdn, ".")
  # ICE server
  ice_uri = var.ice_uri
  ice_user = var.ice_user
  ice_password = var.ice_password
  # Contianer registry
  cr_server   = var.cr_server
  cr_username = var.cr_username
  cr_password = var.cr_password
  # Storage
  storage_account_rg   = azurerm_resource_group.this.name
  storage_account_name = local.storage_account_name
  # IotHub
  iothub_rg        = azurerm_resource_group.this.name
  iothub_name      = local.iothub_name
  iothub_device_id = module.iot_edge.device_id
  # EventHub
  eventhub_namespace_rg       = azurerm_eventhub_namespace.this.resource_group_name
  eventhub_namespace          = azurerm_eventhub_namespace.this.name
  eventhub                    = azurerm_eventhub.this.name
  eventhub_consumer_group     = azurerm_eventhub_consumer_group.this.name
  eventhub_authorization_rule = azurerm_eventhub_authorization_rule.this.name
  eventhub_type               = var.eventhub_type
  mqtt_topic                  = var.mqtt_topic
  mqtt_broker                 = var.mqtt_broker
  # Postgres
  az_pg_server_rg   = azurerm_resource_group.this.name
  az_pg_server      = module.observ_cloud_infra.az_pg_server
  az_pg_db_password = var.pg_db_password
  # Web Server
  web_edition          = var.web_edition
  web_admin_email      = var.web_admin_email
  web_admin_password   = var.web_admin_password
  web_secret_key       = local.web_secret_key
  web_fcm_api_key      = var.web_fcm_api_key
  web_sendgrid_api_key = var.web_sendgrid_api_key
  web_host_url         = var.web_host_url
  web_email_lang       = var.web_email_lang

  # Linebot
  linebot_channel_secret = var.linebot_channel_secret
  linebot_access_token   = var.linebot_access_token

  depends_on = [
    module.observ_cloud_ingress_controller,
    module.iot_edge,
    azurerm_eventhub_consumer_group.this
  ]
}

module "observ_edge_infra" {
  source         = "./../../modules/observ-edge-infra/"
  rg_name        = azurerm_resource_group.this.name
  aks_name       = local.aks_edge_name
  aks_vm_size    = var.aks_edge_vm_size
  aks_dns_prefix = local.aks_edge_dns_prefix
  tags           = var.tags

  depends_on = [
    azurerm_resource_group.this
  ]
}

module "observ_edge_nvidia_device_plugin" {

  source        = "./../../modules/aks-nvidia-device-plugin/"
  cr_server     = var.cr_server
  cr_username   = var.cr_username
  cr_password   = var.cr_password
  chart_version = var.image_tag

  providers = {
    helm       = helm.edge
    kubernetes = kubernetes.edge
  }

  depends_on = [
    module.observ_edge_infra
  ]
}

module "iot_edge" {

  source       = "./../../modules/az-iothub-device/"
  iothub_rg    = azurerm_resource_group.this.name
  iothub_name  = local.iothub_name
  device_id    = local.device_id
  edge_enabled = true


  depends_on = [
    module.observ_cloud_infra
  ]
}

module "observ_edge" {
  source = "./../../modules/observ-edge/"
  # AMS
  suffix                   = var.suffix
  ams_account_rg           = azurerm_resource_group.this.name
  ams_storage_account_rg   = azurerm_storage_account.this.resource_group_name
  ams_storage_account_name = azurerm_storage_account.this.name
  # IotHub
  iothub_device_id         = module.iot_edge.device_id
  iothub_connection_string = module.iot_edge.connection_string
  # EventHub
  eventhub_namespace_rg       = azurerm_eventhub_namespace.this.resource_group_name
  eventhub_namespace          = azurerm_eventhub_namespace.this.name
  eventhub                    = azurerm_eventhub.this.name
  eventhub_authorization_rule = azurerm_eventhub_authorization_rule.this.name
  # Contianer
  cr_server   = var.cr_server
  cr_username = var.cr_username
  cr_password = var.cr_password
  image_tag   = var.image_tag
  # Web Server
  web_host           = trimsuffix(module.observ_cloud_ingress_controller.fqdn, ".")
  web_admin_password = var.web_admin_password
  web_admin_email    = var.web_admin_email
  tags               = var.tags

  providers = {
    helm       = helm.edge
    kubernetes = kubernetes.edge
  }

  depends_on = [
    module.observ_edge_infra,
    module.observ_edge_nvidia_device_plugin,
    module.iot_edge,
    azurerm_eventhub_consumer_group.this
  ]
}
