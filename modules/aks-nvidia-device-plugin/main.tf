resource "null_resource" "download_chart" {
  provisioner "local-exec" {
    command = <<-EOT
      HELM_EXPERIMENTAL_OCI=1 helm registry login ${var.cr_server} --username ${var.cr_username} --password ${var.cr_password}
      HELM_EXPERIMENTAL_OCI=1 helm chart remove ${var.cr_server}/helm/${local.chart_name}:${var.chart_version}
      HELM_EXPERIMENTAL_OCI=1 helm chart pull ${var.cr_server}/helm/${local.chart_name}:${var.chart_version}
      HELM_EXPERIMENTAL_OCI=1 helm chart export ${var.cr_server}/helm/${local.chart_name}:${var.chart_version} --destination ${local.helm_export_path}
    EOT
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "this" {
  name       = var.helm_release_name
  repository = local.helm_export_path
  chart      = local.chart_name
  namespace  = kubernetes_namespace.this.metadata[0].name

  set {
    name  = "image.repository"
    value = var.image_repository
  }
  set {
    name  = "image.tag"
    value = var.image_tag
  }
  set {
    name  = "namespace"
    value = kubernetes_namespace.this.metadata[0].name
  }

  depends_on = [
    null_resource.download_chart,
    kubernetes_namespace.this
  ]
}
