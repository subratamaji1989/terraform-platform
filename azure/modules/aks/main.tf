# Creates the AKS Cluster
resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.cluster_name}-dns"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name       = "default"
    node_count = var.default_node_pool.enable_auto_scaling ? null : var.default_node_pool.node_count
    vm_size    = var.default_node_pool.vm_size
    min_count  = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.min_count : null
    max_count  = var.default_node_pool.enable_auto_scaling ? var.default_node_pool.max_count : null
    vnet_subnet_id      = var.vnet_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  # Network settings for the cluster.
  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.21.0.0/16" # Example CIDR, consider making this a variable
    dns_service_ip = "10.21.0.10"   # Example IP, consider making this a variable
  }
}

# # Creates additional user node pools
# resource "azurerm_kubernetes_cluster_node_pool" "user_pools" {
#   for_each              = var.node_pools
#   name                  = each.value.name
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
#   vm_size               = each.value.vm_size
#   vnet_subnet_id        = var.vnet_subnet_id
#   availability_zones    = each.value.availability_zones
#   mode                  = each.value.mode
#   os_disk_size_gb       = each.value.os_disk_size_gb
#   os_type               = each.value.os_type
#   priority              = each.value.priority
#   node_labels           = each.value.node_labels
#   tags                  = merge(var.tags, each.value.tags)
#   # When autoscaling is enabled, node_count must be null.
#   # When it's disabled, min_count and max_count should be null. (Note: enable_auto_scaling is guaranteed by optional(bool, false) in variables.tf)
#   node_count          = each.value.enable_auto_scaling ? null : each.value.node_count
#   min_count           = each.value.enable_auto_scaling ? each.value.min_count : null
#   max_count           = each.value.enable_auto_scaling ? each.value.max_count : null
#   enable_auto_scaling = each.value.enable_auto_scaling
# }