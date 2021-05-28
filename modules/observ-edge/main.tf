resource "azurerm_media_services_account" "this" {
  name                = var.ams_account_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = data.azurerm_resource_group.this.location

  storage_account {
    id         = data.azurerm_storage_account.this.id
    is_primary = true
  }

  identity {
    type = "SystemAssigned"
  }

  storage_authentication_type = "System"
  tags                        = var.tags

}

resource "azuread_application" "stream_agent" {
  display_name = "stream_agent"

  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"

    resource_access {
      id   = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "stream_agent" {
  application_id = azuread_application.stream_agent.application_id
}

resource "azuread_service_principal_password" "stream_agent" {
  service_principal_id = azuread_service_principal.stream_agent.id
  description          = "Stream agent managed password"
  value                = "VT=uSgbTanZhyz@%nL9Hpd+Tfay_MRV#"
  end_date             = "2099-01-01T01:02:03Z"
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = "observ-${terraform.workspace}"
  }
}

resource "kubernetes_secret" "ams" {
  metadata {
    name      = "ams"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    AMS_CLIENT                   = azuread_service_principal.stream_agent.object_id
    AMS_TENANT_ID                = data.azurerm_client_config.current.tenant_id
    AMS_KEY                      = azuread_service_principal_password.stream_agent.value
    AMS_SUBSCRIPTION_ID          = data.azurerm_client_config.current.subscription_id
    AMS_ACCOUNT_NAME             = azurerm_media_services_account.this.name
    AMS_RESOURCE_GROUP_NAME      = azurerm_media_services_account.this.resource_group_name
    AM_STORAGE_CONNECTION_STRING = data.azurerm_storage_account.this.primary_connection_string
    AM_STORAGE_ACCOUNT_KEY       = data.azurerm_storage_account.this.primary_access_key
    AM_STORAGE_ACCOUNT_NAME      = data.azurerm_storage_account.this.name
    AMS_ENCODER_PRESET_NAME      = "H264SingleBitrate720p"
    AMS_STREAM_POLICY_NAME       = "Predefined_ClearStreamingOnly"

  }
  type = "Opaque"
}

resource "kubernetes_secret" "iotedge" {
  metadata {
    name      = "iotedge"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    IOT_CONNECTION_STRING = var.iothub_connection_string
    DEVICE_ID             = var.iothub_device_id
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
    EVENTHUB_CONNECTION_STRING = var.eventhub_connection_string
  }
  type = "Opaque"
}

resource "kubernetes_config_map" "stream_agent" {
  metadata {
    name      = "stream-agent"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    DEEPSTREAM     = "False"
    WS_PATH        = "webrtc-server"
    CENTERNET_HOST = "triton-server-centernet"
    CENTERNET_PORT = "8000"
    MMDET_HOST     = "triton-server-mmdet"
    MMDET_PORT     = "8000"
  }
}

resource "kubernetes_secret" "web" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.this.metadata[0].name
  }

  data = {
    WEB_ACCESS_TOKEN  = ""
    WEB_REFRESH_TOKEN = ""
    WEB_EMAIL         = var.web_admin_email
    WEB_PASS          = var.web_admin_password
    WEB_SERVER_URL    = format("http://%s/", var.web_host)
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
  name       = "observ-edge-${terraform.workspace}"
  repository = local.helm_export_path
  chart      = local.helm_chart_name
  namespace  = kubernetes_namespace.this.metadata[0].name

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
    kubernetes_secret.ams,
    kubernetes_secret.iotedge,
    kubernetes_secret.web,
    kubernetes_secret.acr_secret,
    kubernetes_config_map.stream_agent,
  ]
}
