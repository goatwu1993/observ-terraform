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
  default     = "Standard_DS2_v2"
}

variable "aks_dns_prefix" {
  description = "DNS prefix of AKS"
  type        = string
}

variable "iothub_name" {
  description = "Name of iothub"
  type        = string
}

variable "iothub_rg" {
  description = "Resource group of iothub"
  type        = string
}

variable "pg_server_name" {
  description = "Name of Azure Database for Postgresql"
  type        = string
}

variable "pg_admin_login" {
  description = "Username of admin of Azure Database for Postgresql"
  type        = string
}

variable "pg_admin_login_password" {
  description = "Password of admin of Azure Database for Postgresql"
  type        = string
}

variable "pg_sku_name" {
  description = "Sku name of Azure Database for Postgresql"
  type        = string
  default     = "GP_Gen5_4"
}

variable "pg_version" {
  description = "Version of Azure Database for Postgresql"
  type        = string
  default     = "11"
}

variable "pg_storage_mb" {
  description = "Size of Azure Database for Postgresql"
  type        = number
  default     = 640000
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
