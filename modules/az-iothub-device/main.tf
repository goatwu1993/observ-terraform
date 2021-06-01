resource "null_resource" "autoinstall" {
  provisioner "local-exec" {
    command = <<-EOT
      az config set extension.use_dynamic_install=yes_without_prompt
    EOT
  }
}

resource "null_resource" "device" {

  triggers = {
    iothub_name = data.azurerm_iothub.this.name
    device_id   = var.device_id
  }

  provisioner "local-exec" {
    when    = create
    command = "az iot hub device-identity create --device-id ${self.triggers.device_id} ${var.edge_enabled ? "--edge-enabled" : ""} --hub-name ${self.triggers.iothub_name}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "az iot hub device-identity delete --device-id ${self.triggers.device_id} --hub-name ${self.triggers.iothub_name}"
  }

  depends_on = [
    data.azurerm_iothub.this,
    data.azurerm_resource_group.this,
    null_resource.autoinstall
  ]
}

data "external" "device_iothub_connection_string" {
  program = ["bash", "-c", "az iot hub device-identity connection-string show --device-id ${null_resource.device.triggers.device_id} --hub-name ${null_resource.device.triggers.iothub_name}"]
}
