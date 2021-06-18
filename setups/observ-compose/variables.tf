variable "suffix" {
  description = "Suffix of all resources"
  type        = string
  validation {
    condition     = can(regex("^[0-9a-z]+$", var.suffix))
    error_message = "For the suffix value only a-z and 0-9 are allowed."
  }
}

variable "rg_location" {
  description = "Location of resources"
  type        = string
  default     = "westus2"
}

variable "aks_cloud_vm_size" {
  description = "VM size of default node group of AKS"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "pg_admin_login" {
  description = "Username of admin of Azure Database for Postgresql"
  type        = string
  default     = "psqladmin"
}

variable "pg_admin_login_password" {
  description = "Password of admin of Azure Database for Postgresql"
  type        = string
  sensitive   = true
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

variable "pg_db_password" {
  description = "Password for database user"
  type        = string
  sensitive   = true
}

variable "image_tag" {
  description = "Tag of this project"
  type        = string
  default     = "1.5.0"
}

variable "web_admin_email" {
  description = "Web server admin email"
  type        = string
}

variable "web_admin_password" {
  description = "Web server admin password"
  type        = string
  sensitive   = true
}

variable "web_fcm_api_key" {
  description = "Web server FCM api key"
  type        = string
}

variable "cr_server" {
  description = "Server name of existing private container registry"
  type        = string
  default     = "observrelease.azurecr.io"
}

variable "cr_username" {
  description = "Username of existing private container registry"
  type        = string
  default     = "fbf9b1ee-02b8-4452-ab7a-bdf16e47ae98"
}

variable "cr_password" {
  description = "Password of existing private container registry"
  type        = string
  default     = "KNDTdJGVh8fyFWpa9DZD~.mW9tb38_IRxD"
}

variable "aks_edge_vm_size" {
  description = "VM size of default node group of AKS"
  type        = string
  default     = "standard_nc4as_t4_v3"
}

variable "tags" {
  description = "Tags of all resources"
  type = object({
    provider = string
  })
  default = {
    provider = "observ-terraform"
  }
}

variable "linebot_access_token" {
  description = "Linebot access token"
  type        = string
  default     = ""
}

variable "linebot_channel_secret" {
  description = "Linebot channel secret"
  type        = string
  default     = ""
}
