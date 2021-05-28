terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.59.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.2"
    }
  }
  required_version = ">= 0.14"
}
