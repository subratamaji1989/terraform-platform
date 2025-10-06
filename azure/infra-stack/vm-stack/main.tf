# main.tf - Main composition for deploying a complete Azure VM stack.

locals {
  # Define common values once to be reused across the stack.
  location            = "East US"
  resource_group_name = "${var.vnet.name}-rg" # A single resource group for the entire stack.
  tags                = var.tags
}

# Create a single Resource Group to contain all resources for this stack.
resource "azurerm_resource_group" "stack_rg" {
  name     = local.resource_group_name
  location = local.location
  tags     = local.tags
}

# Instantiate the network module to create the VNet and subnets.
module "network" {
  source = "../../modules/network"

  resource_group_name = azurerm_resource_group.stack_rg.name
  location            = azurerm_resource_group.stack_rg.location
  vnet_name           = var.vnet.name
  vnet_address_space  = var.vnet.address_space
  subnets             = var.subnets
  tags                = local.tags
}

# Create Network Security Groups (NSGs) based on the security.yaml file.
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.nsgs
  name                = each.value.name
  location            = azurerm_resource_group.stack_rg.location
  resource_group_name = azurerm_resource_group.stack_rg.name
  tags                = local.tags

  # Create security rules within each NSG.
  dynamic "security_rule" {
    for_each = each.value.rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

# Associate NSGs to subnets based on the 'nsg_key' defined in the subnets variable.
# This creates an association for each subnet that has an 'nsg_key' specified.
resource "azurerm_subnet_network_security_group_association" "app_subnet_nsg_assoc" {
  for_each = {
    for k, v in var.subnets : k => v if try(v.nsg_key, null) != null
  }

  subnet_id                 = module.network.subnet_ids[each.key]
  network_security_group_id = azurerm_network_security_group.nsg[each.value.nsg_key].id
}

# Instantiate the VM module to create virtual machines.
module "vm" {
  source = "../../modules/vm"

  resource_group_name = azurerm_resource_group.stack_rg.name
  location            = azurerm_resource_group.stack_rg.location
  subnet_ids          = module.network.subnet_ids
  instances           = var.instances
  admin_public_key    = var.admin_public_key
  tags                = local.tags
}