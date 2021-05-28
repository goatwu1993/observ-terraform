variable "namespace" {
  description = "Namespace of Kubernetes"
  type        = string
}

variable "image_tag" {
  description = "Tag of this project"
  type        = string
}

variable "dns" {
  description = "DNS of this project"
  type        = string
}

variable "web_admin" {
  description = "Admin email and password"

  type = object({
    email    = string
    password = string
  })
  default = {
    email    = ""
    password = ""
  }
}

variable "web_secret_key" {
  description = "Web server secret key to hash password"
  type        = string
}

variable "web_fcm_api_key" {
  description = "Web server FCM api key"
  type        = string
}

variable "storage_account_rg" {
  description = "Resource group of storage account"
  type        = string
}

variable "storage_account_name" {
  description = "Name of storage account"
  type        = string
}

variable "storage_container_name" {
  description = "Name of storage container"
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

variable "iothub_device_id" {
  description = "IoTHub Device Id"
  type        = string
}

variable "cr_server" {
  description = "Server name of existing private container registry"
  type        = string
}

variable "cr_username" {
  description = "Username of existing private container registry"
  type        = string
}

variable "cr_password" {
  description = "Password of existing private container registry"
  type        = string
}

variable "az_pg_server" {
  description = "Azure PostgreSQL server Name"
  type        = string
}

variable "az_pg_server_rg" {
  description = "Resource group of Azure PostgreSQL server"
  type        = string
}

variable "az_pg_db_name" {
  description = "Name of database of Azure PostgreSQL server"
  type        = string
}

variable "az_pg_db_username" {
  description = "Username of role with privilege granted to database of Azure PostgreSQL server"
  type        = string
}

variable "az_pg_db_password" {
  description = "Password of role with privilege granted to database of Azure PostgreSQL server"
  type        = string
}

variable "az_pg_firewall_rule_name" {
  description = "Firewall name of to allow terraform client connect to Azure PostgreSQL server"
  type        = string
}

variable "helm_release_name" {
  description = "Name of helm release"
  type        = string
  default     = ""
}

variable "eventhub_name" {
  description = "EventHub name"
  type        = string
}

variable "eventhub_consumer_group" {
  description = "Name of EventHub Consumer group"
  type        = string
}

variable "eventhub_connection_string" {
  description = "EventHub Connction String"
  type        = string
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

variable "web_admin_email" {
  description = "Web server admin email"
  type        = string
}

variable "web_admin_password" {
  description = "Web server admin password"
  type        = string
}
