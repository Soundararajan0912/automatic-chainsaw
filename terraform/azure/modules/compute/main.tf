locals {
  cloud_init = templatefile("${path.module}/cloud-init.yaml.tpl", {
    admin_username    = var.admin_username
    nginx_server_name = var.nginx_server_name
  })
}

resource "azurerm_network_interface" "vm" {
  name                = "${var.resource_group_name}-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.resource_group_name}-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [azurerm_network_interface.vm.id]
  custom_data           = base64encode(local.cloud_init)
  encryption_at_host_enabled = var.encryption_at_host_enabled

  disable_password_authentication = false

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.vm_os_disk_size_gb
  }

  source_image_id = var.custom_image_id

  /*
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-noble"
    sku       = "24_04-lts"
    version   = "latest"
  }
  */

  computer_name = var.computer_name

  boot_diagnostics {
    storage_account_uri = null
  }

  tags = var.tags
}
