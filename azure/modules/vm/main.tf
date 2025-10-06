# main.tf - Defines Azure Virtual Machine resources.

# Create a network interface for each VM.
resource "azurerm_network_interface" "nic" {
  for_each            = var.instances
  name                = "${each.key}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_ids[each.value.subnet_key]
    private_ip_address_allocation = "Dynamic"
  }

  tags = each.value.tags
}

# Create the Azure Linux Virtual Machine.
# This uses a for_each loop to create multiple VMs based on the input map.
resource "azurerm_linux_virtual_machine" "vm" {
  for_each              = var.instances
  name                  = each.key
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = each.value.vm_size
  admin_username        = each.value.admin_username
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  # For simplicity, this uses password-less SSH with a provided public key.
  # In production, consider using Azure AD login or sourcing keys from Azure Key Vault.
  admin_ssh_key {
    username   = each.value.admin_username
    public_key = var.admin_public_key
  }

  # Define the OS disk.
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Define the source image for the VM.
  source_image_reference {
    publisher = each.value.image.publisher
    offer     = each.value.image.offer
    sku       = each.value.image.sku
    version   = each.value.image.version
  }

  tags = each.value.tags
}