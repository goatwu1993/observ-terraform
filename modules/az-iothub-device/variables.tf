variable "iothub_rg" {
  description = "Resource group of IoTHub"
  type        = string
}

variable "iothub_name" {
  description = "Name of IoTHub"
  type        = string
}

variable "device_id" {
  description = "Name of Device"
  type        = string
}

variable "edge_enabled" {
  description = "Edge enabled. Default to false"
  type        = string
  default     = false
}
