# This is the main composition file that orchestrates all Azure modules for a unified stack.
# It creates resources conditionally based on the variables provided from the YAML files.

# --- Provider Configuration ---
# All modules inherit this provider configuration.
provider "azurerm" {
  features {}
}

# --- Resource Group ---
# Creates resource groups based on the 'rg' variable map.
resource "azurerm_resource_group" "this" {
  for_each = var.rg
  name     = each.value.name
  location = each.value.location
  tags     = try(each.value.tags, {})
}

locals {
  # Assumes a single primary resource group is used for all modules.
  # This dynamically finds the first (and only) resource group defined.
  primary_rg_key      = keys(var.rg)[0]
  primary_rg_name     = azurerm_resource_group.this[local.primary_rg_key].name
  primary_rg_location = azurerm_resource_group.this[local.primary_rg_key].location
}

# --- Random String for Unique Naming ---
# This resource generates a random suffix to ensure global uniqueness for certain resources like storage accounts.
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# --- Network Module ---
# Deploys a Virtual Network and subnets if a 'virtual_network' is defined.
module "network" {
  source              = "../modules/network"
  count               = var.vnet != null ? 1 : 0
  resource_group_name = local.primary_rg_name
  location            = local.primary_rg_location
  vnet_name           = try(var.vnet.name, null) # Use try() for safety
  vnet_address_space   = try(var.vnet.address_space, []) # Use try() for safety
  subnets             = try(var.subnets, {})
  tags                = try(var.vnet.tags, {})
}

# --- Network Security Group Module ---
# Creates Network Security Groups and their rules.
module "nsg" {
  source                = "../modules/nsg"
  count                 = var.nsgs != {} ? 1 : 0
  resource_group_name   = local.primary_rg_name
  location              = local.primary_rg_location
  security_groups       = var.nsgs
  subnet_ids_by_key     = try(module.network[0].subnet_ids, {})
}

# --- Storage Module ---
# Deploys Azure Storage Accounts.
module "storage" {
  source              = "../modules/storage"
  count               = var.storage_accounts != {} ? 1 : 0
  resource_group_name = local.primary_rg_name
  location            = local.primary_rg_location
  storage_accounts    = var.storage_accounts
  unique_suffix       = random_string.suffix.result
}

# --- ACR Module ---
# Deploys Azure Container Registries.
module "acr" {
  source                = "../modules/acr"
  count                 = var.container_registries != {} ? 1 : 0
  resource_group_name   = local.primary_rg_name
  location              = local.primary_rg_location
  container_registries  = var.container_registries
}

# --- Database Module (e.g., Azure SQL) ---
# Deploys Azure SQL Servers and Databases.
module "database" {
  source                = "../modules/database"
  count                 = var.sql_servers != {} ? 1 : 0
  resource_group_name   = local.primary_rg_name
  location              = local.primary_rg_location
  sql_servers           = var.sql_servers
}

# --- Application Gateway Module (Layer 7) ---
# Deploys an Azure Application Gateway.
module "app_gateway" {
  for_each              = var.application_gateways
  source                = "../modules/app_gateway"
  resource_group_name   = local.primary_rg_name
  location              = local.primary_rg_location

  # Pass the entire gateway configuration object to the module
  vnet_id           = try(module.network[0].vnet_id, null)
  gateway_subnet_id = try(module.network[0].subnet_ids[each.value.subnet_key], null)
  vm_nic_ids_by_key = { for k, v in module.vm : k => v.network_interface_ids }
  tags              = var.tags
  # Pass all other attributes from the application_gateways variable
  gateway_name      = each.value.name
  sku_name          = each.value.sku_name
  sku_tier          = each.value.sku_tier
  sku_capacity      = each.value.sku_capacity
  listeners         = each.value.listeners
  backend_pools     = each.value.backend_pools
  http_settings     = each.value.http_settings
  routing_rules     = each.value.routing_rules
}

# --- API Management Module ---
module "apim" {
  source              = "../modules/apim"
  count               = var.api_management_services != {} ? 1 : 0
  resource_group_name = local.primary_rg_name
  location            = local.primary_rg_location
  apim_services       = var.api_management_services
}

# --- AKS Module ---
# Deploys an Azure Kubernetes Service (AKS) cluster.
module "aks" {
  source              = "../modules/aks"
  count               = var.cluster != null ? 1 : 0
  resource_group_name   = local.primary_rg_name
  location            = local.primary_rg_location

  # Pass the specific values for the cluster to the module
  cluster_name       = var.cluster.name
  kubernetes_version = var.cluster.kubernetes_version
  default_node_pool  = var.cluster.default_node_pool
  node_pools         = var.cluster.node_pools
  tags               = var.tags
  vnet_subnet_id     = try(module.network[0].subnet_ids[var.cluster.subnet_keys[0]], null) # Assumes the first subnet key is for the node pool
}

# --- VM Module ---
# Deploys one or more Azure Virtual Machines.
module "vm" {
  for_each              = var.vm
  source                = "../modules/vm"
  resource_group_name   = local.primary_rg_name
  location              = local.primary_rg_location

  # Pass the specific values for each VM to the module
  name                  = each.value.name
  size                  = each.value.size
  admin_username        = each.value.admin_username
  admin_public_key      = try(each.value.admin_public_key, var.admin_public_key)
  admin_password        = try(each.value.admin_password, null)
  image                 = try(each.value.image, null)
  subnet_ids            = [try(module.network[0].subnet_ids[each.value.subnet_key], null)] # Pass as a list
  network_security_group_id = try(module.nsg[0].nsg_ids[each.value.nsg_key], null)
}

# --- Load Balancer Module (Layer 4) ---
# Deploys a standard Azure Load Balancer.
module "lb" {
  source                = "../modules/lb"
  count                 = var.load_balancers != {} ? 1 : 0
  resource_group_name   = local.primary_rg_name
  location              = local.primary_rg_location
  load_balancers        = var.load_balancers
  # Construct a map of NIC IDs and their target LB keys for each VM that defines a 'load_balancer_key'.
  vm_nic_ids_by_vm_key  = {
    for vm_key, vm_val in var.vm :
    vm_key => { nic_id = module.vm[vm_key].network_interface_ids, lb_key = vm_val.load_balancer_key }
    if try(vm_val.load_balancer_key, null) != null
  }

  # Explicitly depend on the vm module to ensure correct creation order.
  depends_on = [module.vm]
}