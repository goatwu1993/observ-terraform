terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.1.0"
    }
  }
  required_version = ">= 0.14"
}
