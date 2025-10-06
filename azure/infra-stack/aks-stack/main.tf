# main.tf - Main composition for deploying a complete AKS stack.

# Location is defined once and reused for all resources for consistency.
locals { # You can also make this a variable
  location = "East US"
  tags     = var.tags
}

# Create a single Resource Group for the entire stack for easier management.
resource "azurerm_resource_group" "stack_rg" {
  name     = "${var.cluster.name}-rg"
  location = local.location
  tags     = local.tags
}

# Instantiate the network module to create the VNet and subnets.
module "network" {
  source = "../../modules/network"

  resource_group_name = azurerm_resource_group.stack_rg.name
  location            = local.location
  vnet_name           = var.vnet.name
  vnet_address_space  = var.vnet.address_space
  subnets             = var.subnets
  tags                = local.tags
}

# Create a Private DNS Zone for the private AKS cluster.
# This allows resources within the VNet to resolve the private FQDN of the Kubernetes API server.
resource "azurerm_private_dns_zone" "aks_private_zone" {
  name                = "privatelink.${local.location}.azmk8s.io"
  resource_group_name = azurerm_resource_group.stack_rg.name
  tags                = local.tags
}

# Link the Private DNS Zone to the Virtual Network.
resource "azurerm_private_dns_zone_virtual_network_link" "aks_private_zone_link" {
  name                  = "${var.vnet.name}-dns-link"
  resource_group_name   = azurerm_resource_group.stack_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.aks_private_zone.name
  virtual_network_id    = module.network.vnet_id
}

# Instantiate the Application Gateway module.
module "app_gateway" {
  source = "../../modules/app_gateway"

  gateway_name        = var.app_gateway.name
  resource_group_name = azurerm_resource_group.stack_rg.name
  location            = local.location
  gateway_subnet_id   = module.network.subnet_ids["app_gateway_subnet"]
  vnet_id             = module.network.vnet_id
  sku_name            = var.app_gateway.sku.name
  sku_tier            = var.app_gateway.sku.tier
  sku_capacity        = var.app_gateway.sku.capacity
  frontend_port       = var.app_gateway.frontend_port
  backend_port        = var.app_gateway.backend_port
  tags                = local.tags
}

# Instantiate the AKS module to create the Kubernetes cluster.
# It uses the outputs from the network module (like the subnet ID) to link the resources.
module "aks" {
  source = "../../modules/aks"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.aks_private_zone_link, module.app_gateway] # Ensure dependencies are created first

  resource_group_name = azurerm_resource_group.stack_rg.name
  location            = local.location
  cluster_name        = var.cluster.name
  kubernetes_version  = var.cluster.kubernetes_version
  vnet_subnet_id      = module.network.subnet_ids["aks_subnet"]
  private_cluster_enabled = true # Enforce private cluster
  private_dns_zone_id = azurerm_private_dns_zone.aks_private_zone.id
  node_pools          = var.cluster.node_pools
  tags                = local.tags
}