resource "azurerm_storage_container" "this" {
  name                 = local.storage_container_name
  storage_account_name = data.azurerm_storage_account.this.name
}

resource "azurerm_postgresql_firewall_rule" "this" {
  name                = local.az_pg_firewall_rule_name
  resource_group_name = data.azurerm_postgresql_server.this.resource_group_name
  server_name         = data.azurerm_postgresql_server.this.name
  start_ip_address    = jsondecode(data.http.my_public_ip.body).ip
  end_ip_address      = jsondecode(data.http.my_public_ip.body).ip
}

resource "azurerm_postgresql_database" "this" {
  name                = local.az_pg_db_name
  resource_group_name = data.azurerm_postgresql_server.this.resource_group_name
  server_name         = data.azurerm_postgresql_server.this.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  # Workaround for destroy error
  depends_on = [postgresql_role.this]
}

resource "postgresql_role" "this" {
  name                = local.az_pg_db_username
  login               = true
  password            = var.az_pg_db_password
  skip_reassign_owned = true
}

resource "postgresql_grant" "grant_all" {
  database    = azurerm_postgresql_database.this.name
  role        = postgresql_role.this.name
  object_type = "database"
  privileges  = ["CONNECT", "TEMPORARY", "CREATE"]
}

resource "postgresql_extension" "postgis" {
  name         = "postgis"
  database     = azurerm_postgresql_database.this.name
  drop_cascade = true
}

resource "postgresql_extension" "pgcrypto" {
  name         = "pgcrypto"
  database     = azurerm_postgresql_database.this.name
  drop_cascade = true
}

# TODO: replace workspace with suffix

resource "kubernetes_namespace" "this" {
  metadata {
    name = local.namespace
  }

  # Error occurs if terraform try to drop database while any pod still connect to it
  # Remove if helm uninstall can -wait .
  depends_on = [
    azurerm_postgresql_database.this
  ]
}

resource "kubernetes_secret" "acr_secret" {
  metadata {
    name      = "acr-secret"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
{
  "auths": {
    "${var.cr_server}": {
      "auth": "${base64encode("${var.cr_username}:${var.cr_password}")}"
    }
  }
}
DOCKER
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "null_resource" "download_chart" {
  provisioner "local-exec" {
    command = <<-EOT
      HELM_EXPERIMENTAL_OCI=1 helm registry login ${var.cr_server} --username ${var.cr_username} --password ${var.cr_password}
      HELM_EXPERIMENTAL_OCI=1 helm chart remove ${var.cr_server}/helm/${local.helm_chart_name}:${var.image_tag}
      HELM_EXPERIMENTAL_OCI=1 helm chart pull ${var.cr_server}/helm/${local.helm_chart_name}:${var.image_tag}
      HELM_EXPERIMENTAL_OCI=1 helm chart export ${var.cr_server}/helm/${local.helm_chart_name}:${var.image_tag} --destination ${local.helm_export_path}
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "helm_release" "this" {
  name       = local.helm_release_name
  repository = local.helm_export_path
  chart      = local.helm_chart_name
  namespace  = kubernetes_namespace.this.metadata[0].name

  set {
    name  = "dns"
    value = var.dns
  }

  set {
    name  = "image.tag"
    value = var.image_tag
  }

  set {
    name  = "image.cr"
    value = var.cr_server
  }

  set {
    name  = "imagePullSecrets[0].name"
    value = kubernetes_secret.acr_secret.metadata[0].name
  }

  set {
    name  = "externalPostgresql.host"
    value = trimsuffix(data.azurerm_postgresql_server.this.fqdn, ".")
  }

  set {
    name  = "externalPostgresql.port"
    value = 5432
  }

  set {
    name  = "externalPostgresql.username"
    value = "${postgresql_role.this.name}@${azurerm_postgresql_database.this.server_name}"
  }

  set {
    name  = "externalPostgresql.password"
    value = postgresql_role.this.password
  }
  set {
    name  = "externalPostgresql.database"
    value = azurerm_postgresql_database.this.name
  }

  set {
    name  = "observ.web.admin.email"
    value = var.web_admin_email
  }

  set {
    name  = "observ.web.admin.password"
    value = var.web_admin_password
  }

  set {
    name  = "observ.web.fcmApiKey"
    value = var.web_fcm_api_key
  }

  set {
    name  = "observ.web.secretKey"
    value = var.web_secret_key
  }

  set {
    name  = "storage.azure.storageAccount"
    value = data.azurerm_storage_account.this.name
  }

  set {
    name  = "storage.azure.container"
    value = azurerm_storage_container.this.name
  }

  set {
    name  = "storage.azure.accountKey"
    value = data.azurerm_storage_account.this.primary_access_key
  }

  set {
    name  = "message.azure.iothub.connectionString"
    value = data.azurerm_iothub_shared_access_policy.this.primary_connection_string
  }

  set {
    name  = "message.azure.iothub.deviceId"
    value = var.iothub_device_id
  }

  set {
    name  = "message.azure.eventhub.name"
    value = data.azurerm_eventhub.this.name
  }

  set {
    name  = "message.azure.eventhub.consumerGroup"
    value = data.azurerm_eventhub_consumer_group.this.name
  }

  set {
    name  = "message.azure.eventhub.connectionString"
    value = data.azurerm_eventhub_authorization_rule.this.primary_connection_string
  }

  set {
    name  = "lineBot.accessToken"
    value = var.linebot_access_token
  }

  set {
    name  = "lineBot.channelSecret"
    value = var.linebot_channel_secret
  }

  # Helm will read envFrom secret. However there is no way terraform to know
  # Explicitly declare depends on secrets.
  depends_on = [
    null_resource.download_chart,
    kubernetes_namespace.this,
    azurerm_postgresql_database.this
  ]
}
