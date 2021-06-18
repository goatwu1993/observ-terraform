locals {
  helm_export_path          = "./helm_export"
  helm_chart_name           = "observ-edge"
  media_services_account    = "observ${var.suffix}"
  stream_agent_display_name = "stream_agent_${var.suffix}"
  namespace                 = "observ-edge-${var.suffix}"
  helm_release              = "observ-edge-${var.suffix}"
}
