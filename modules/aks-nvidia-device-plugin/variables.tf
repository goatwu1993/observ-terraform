variable "image_repository" {
  description = "Image repository of nvidia device plugin daemon"
  type        = string
  default     = "mcr.microsoft.com/oss/nvidia/k8s-device-plugin"
}

variable "image_tag" {
  description = "Image tag of nvidia device plugin daemon"
  type        = string
  default     = "1.11"
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

variable "chart_version" {
  description = "Chart version of nvidia device plugin"
  type        = string
}

variable "namespace" {
  description = "Namespace to install helm"
  type        = string
  default     = "gpu-resources"
}

variable "helm_release_name" {
  description = "Name of helm release"
  type        = string
  default     = "nvidia-device-plugin"
}
