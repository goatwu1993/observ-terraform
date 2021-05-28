variable "aks_name" {
  description = "Name of AKS"
  type        = string
}

variable "aks_rg" {
  description = "Resource group of AKS"
  type        = string
}

variable "aks_public_ip_name" {
  description = "Name of public ip address"
  type        = string
}

variable "tags" {
  description = "Default tags of all resources"
  type = object({
    provider = string
  })
  default = {
    provider = "observ-terraform"
  }
}

variable "controller_replica_count" {
  description = "Controller Replica count"
  type        = number
  default     = 1
}

variable "namespace" {
  description = "Namespace to install helm"
  type        = string
  default     = "nginx-ingress"
}

variable "helm_release_name" {
  description = "Name of helm release"
  type        = string
  default     = "nginx-ingress"
}
