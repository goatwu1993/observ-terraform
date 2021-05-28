output "device_id" {
  value = null_resource.device.triggers.device_id
}

output "connection_string" {
  value = data.external.device_iothub_connection_string.result["connectionString"]
}
