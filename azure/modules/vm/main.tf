# Creates a Network Interface for the VM
resource "azurerm_network_interface" "this" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "ip_configuration" {
    for_each = toset(var.subnet_ids)
    content {
      name                          = "ipconfig-${index(var.subnet_ids, ip_configuration.value)}"
      subnet_id                     = ip_configuration.value
      private_ip_address_allocation = "Dynamic"
      primary                       = index(var.subnet_ids, ip_configuration.value) == 0
    }
  }
}

# Associates the Network Security Group with the Network Interface
resource "azurerm_network_interface_security_group_association" "this" {
  count                     = var.network_security_group_id != null ? 1 : 0
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = var.network_security_group_id
}

# Creates the Azure Virtual Machine
resource "azurerm_linux_virtual_machine" "this" {
  name                  = var.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.size

  # disable_password_authentication = var.admin_public_key != null
  disable_password_authentication = var.admin_public_key != null
  network_interface_ids = [azurerm_network_interface.this.id]
  admin_username        = var.admin_username
  admin_password = var.admin_password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = try(var.image.publisher, "Canonical")
    offer     = try(var.image.offer, "0001-com-ubuntu-server-jammy")
    sku       = try(var.image.sku, "22_04-lts")
    version   = try(var.image.version, "latest")
  }

  depends_on = [azurerm_network_interface_security_group_association.this]
}