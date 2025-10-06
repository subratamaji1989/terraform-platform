# main.tf - Defines the Azure Kubernetes Service (AKS) cluster

# Create a resource group for the AKS cluster.
resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Create the AKS cluster itself.
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "${var.cluster_name}-dns"
  kubernetes_version  = var.kubernetes_version
  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id = var.private_cluster_enabled ? var.private_dns_zone_id : null
  tags                = var.tags

  # Define the default node pool and its settings.
  # This node pool will run system services for Kubernetes.
  # It's kept minimal as workloads will run on separate node pools.
  default_node_pool {
    name           = "systempool"
    node_count     = 1
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = var.vnet_subnet_id
    tags           = var.tags
  }

  # Use a system-assigned managed identity for the cluster.
  # This is a security best practice as it avoids managing service principal credentials.
  identity {
    type = "SystemAssigned"
  }

  # Network settings for the cluster.
  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.21.0.0/16"
    dns_service_ip = "10.21.0.10"
  }

  # Security best practice: Disable local accounts to enforce Azure AD-based authentication.
  local_account_disabled = true
}

# Create additional, data-driven node pools for user workloads.
# This uses a for_each loop to create a node pool for each entry in the var.node_pools map.
resource "azurerm_kubernetes_cluster_node_pool" "user_pools" {
  for_each              = var.node_pools
  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = each.value.vm_size
  node_count            = each.value.enable_auto_scaling ? null : each.value.node_count
  min_count             = each.value.enable_auto_scaling ? each.value.min_count : null
  max_count             = each.value.enable_auto_scaling ? each.value.max_count : null
  enable_auto_scaling   = each.value.enable_auto_scaling
  vnet_subnet_id        = var.vnet_subnet_id
  tags                  = var.tags
}