locals {
  namespace                = "observ-cloud-${var.suffix}"
  helm_export_path         = "./helm_export"
  helm_chart_name          = "observ-cloud"
  helm_release_name        = "observ-cloud-${var.suffix}"
  storage_container_name   = "backend${var.suffix}"
  az_pg_db_name            = "backend_${var.suffix}"
  az_pg_db_username        = "backend_${var.suffix}"
  az_pg_firewall_rule_name = "allow_terraform_client_${var.suffix}"
}
