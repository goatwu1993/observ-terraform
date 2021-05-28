provider "azurerm" {
  features {}
}

provider "postgresql" {
  host            = module.observ_cloud_infra.postgresql_fqdn
  port            = 5432
  database        = "postgres"
  username        = "${var.pg_admin_login}@${module.observ_cloud_infra.postgresql_fqdn}"
  password        = var.pg_admin_login_password
  superuser       = false
  sslmode         = "require"
  connect_timeout = 15
}

provider "kubernetes" {
  host                   = module.observ_cloud_infra.kube_config.0.host
  username               = module.observ_cloud_infra.kube_config.0.username
  password               = module.observ_cloud_infra.kube_config.0.password
  client_certificate     = base64decode(module.observ_cloud_infra.kube_config.0.client_certificate)
  client_key             = base64decode(module.observ_cloud_infra.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(module.observ_cloud_infra.kube_config.0.cluster_ca_certificate)
}

provider "kubernetes" {
  alias                  = "edge"
  host                   = module.observ_edge_infra.kube_config.0.host
  username               = module.observ_edge_infra.kube_config.0.username
  password               = module.observ_edge_infra.kube_config.0.password
  client_certificate     = base64decode(module.observ_edge_infra.kube_config.0.client_certificate)
  client_key             = base64decode(module.observ_edge_infra.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(module.observ_edge_infra.kube_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.observ_cloud_infra.kube_config.0.host
    client_key             = base64decode(module.observ_cloud_infra.kube_config.0.client_key)
    client_certificate     = base64decode(module.observ_cloud_infra.kube_config.0.client_certificate)
    cluster_ca_certificate = base64decode(module.observ_cloud_infra.kube_config.0.cluster_ca_certificate)
  }
}

provider "helm" {
  alias = "edge"
  kubernetes {
    host                   = module.observ_edge_infra.kube_config.0.host
    client_key             = base64decode(module.observ_edge_infra.kube_config.0.client_key)
    client_certificate     = base64decode(module.observ_edge_infra.kube_config.0.client_certificate)
    cluster_ca_certificate = base64decode(module.observ_edge_infra.kube_config.0.cluster_ca_certificate)
  }
}
