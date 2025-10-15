# main.tf - Defines the network resources for Azure

# Create the Virtual Network (VNet).
# This is the fundamental building block for your private network in Azure.
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# Create subnets within the VNet.
# This uses a for_each loop to create multiple subnets based on the input map,
# making the module data-driven and reusable.
resource "azurerm_subnet" "subnets" {
  for_each             = var.subnets
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes
}