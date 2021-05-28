variable "image_tag" {
  description = "Tag of this project"
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

variable "ams_account_rg" {
  description = "Resource group of Azure media service account"
  type        = string
}

variable "ams_account_name" {
  description = "Name of Azure media service account"
  type        = string
}

variable "ams_storage_account_rg" {
  description = "Resource group of Storage Account of Azure media service account"
  type        = string
}

variable "ams_storage_account_name" {
  description = "Name of Storage Account of Azure media service account"
  type        = string
}

variable "web_host" {
  description = "Host of web-server"
  type        = string
}

variable "web_admin_password" {
  description = "Password of admin of web-server"
  type        = string
}

variable "web_admin_email" {
  description = "Email of admin of web-server"
  type        = string
}

variable "iothub_device_id" {
  description = "IoTHub Device Id"
  type        = string
}

variable "iothub_connection_string" {
  description = "IoTHub Device Connection String"
  type        = string
}

variable "eventhub_name" {
  description = "EventHub name"
  type        = string
}

variable "eventhub_connection_string" {
  description = "EventHub Connection String"
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
