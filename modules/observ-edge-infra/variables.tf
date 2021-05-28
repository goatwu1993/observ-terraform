variable "rg_name" {
  description = "Resource group"
  type        = string
}

variable "aks_name" {
  description = "Name of AKS"
  type        = string
}

variable "aks_vm_size" {
  description = "VM size of default node group of AKS"
  type        = string
  default     = "standard_nc4as_t4_v3"
}

variable "aks_dns_prefix" {
  description = "DNS prefix of AKS"
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
