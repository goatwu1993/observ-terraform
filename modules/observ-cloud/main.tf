resource "azurerm_storage_container" "this" {
  name                 = var.storage_container_name
  storage_account_name = data.azurerm_storage_account.this.name
}

resource "azurerm_postgresql_firewall_rule" "this" {
  name                = var.az_pg_firewall_rule_name
  resource_group_name = data.azurerm_postgresql_server.this.resource_group_name
  server_name         = data.azurerm_postgresql_server.this.name
  start_ip_address    = jsondecode(data.http.my_public_ip.body).ip
  end_ip_address      = jsondecode(data.http.my_public_ip.body).ip
}

resource "azurerm_postgresql_database" "this" {
  name                = var.az_pg_db_name
  resource_group_name = data.azurerm_postgresql_server.this.resource_group_name
  server_name         = data.azurerm_postgresql_server.this.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  # Workaround for destroy error
  depends_on = [postgresql_role.this]
}

resource "postgresql_role" "this" {
  name                = var.az_pg_db_username
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

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }

  # Error occurs if terraform try to drop database while any pod still connect to it
  # Remove if helm uninstall can -wait .
  depends_on = [
    azurerm_postgresql_database.this
  ]
}

resource "kubernetes_secret" "iothub" {
  metadata {
    name      = "iothub"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    CONNECTION_STRING      = data.azurerm_iothub_shared_access_policy.this.primary_connection_string
    DEVICE_ID              = var.iothub_device_id
    LINEBOT_ACCESS_TOKEN   = var.linebot_access_token
    LINEBOT_CHANNEL_SECRET = var.linebot_channel_secret
  }
  type = "Opaque"
}

resource "kubernetes_secret" "eventhub" {
  metadata {
    name      = "eventhub"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    EVENTHUB_NAME              = var.eventhub_name
    eventhub_consumer_group    = var.eventhub_consumer_group
    EVENTHUB_CONNECTION_STRING = var.eventhub_connection_string
  }
  type = "Opaque"
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    POSTGRES_HOST     = trimsuffix(data.azurerm_postgresql_server.this.fqdn, ".")
    POSTGRES_PORT     = 5432
    POSTGRES_USER     = "${postgresql_role.this.name}@${azurerm_postgresql_database.this.server_name}"
    POSTGRES_DB       = azurerm_postgresql_database.this.name
    POSTGRES_PASSWORD = postgresql_role.this.password
  }
  type = "Opaque"
}

resource "kubernetes_secret" "django" {
  metadata {
    name      = "django"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    DJANGO_SECRET_KEY  = var.web_secret_key
    AZURE_ACCOUNT_NAME = data.azurerm_storage_account.this.name
    AZURE_CONTAINER    = azurerm_storage_container.this.name
    AZURE_ACCOUNT_KEY  = data.azurerm_storage_account.this.primary_access_key
    FCM_API_KEY        = var.web_fcm_api_key
  }
  type = "Opaque"
}

resource "kubernetes_secret" "django_admin" {
  metadata {
    name      = "django-admin"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    DJANGO_SUPERUSER_EMAIL    = var.web_admin_email
    DJANGO_SUPERUSER_PASSWORD = var.web_admin_password
  }
  type = "Opaque"
}

resource "kubernetes_config_map" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    REDIS_HOST   = "redis"
    REDIS_PORT   = 6379
    REDIS_GPS_DB = 2
  }
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
  name       = var.helm_release_name
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

  # Helm will read envFrom secret. However there is no way terraform to know
  # Explicitly declare depends on secrets.
  depends_on = [
    null_resource.download_chart,
    kubernetes_namespace.this,
    kubernetes_secret.postgres,
    kubernetes_secret.django,
    kubernetes_secret.django_admin,
    kubernetes_secret.iothub,
    kubernetes_secret.eventhub,
    kubernetes_config_map.redis,
    azurerm_postgresql_database.this
  ]
}
