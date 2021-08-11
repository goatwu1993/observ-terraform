variable "suffix" {
  description = "Suffix of all resources"
  type        = string
  validation {
    condition     = can(regex("^[0-9a-z]+$", var.suffix))
    error_message = "For the suffix value only a-z and 0-9 are allowed."
  }
}

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

variable "eventhub_namespace" {
  description = "EventHub namespace"
  type        = string
}

variable "eventhub_namespace_rg" {
  description = "Resource group of EventHub namespace"
  type        = string
}

variable "eventhub" {
  description = "Name of EventHub"
  type        = string
}

variable "eventhub_authorization_rule" {
  description = "Name of EventHub Authorization Rule"
  type        = string
}

variable "eventhub_type" {
  description = "eventhub type"
  type        = string
  default     = ""
}

variable "mqtt_topic" {
  description = "mqtt topic"
  type        = string
  default     = ""
}

variable "mqtt_broker" {
  description = "mqtt broker"
  type        = string
  default     = ""
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
