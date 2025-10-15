# Creates a flattened list of all rules from all load balancers for easier iteration.
locals {
  all_rules = flatten([
    for lb_key, lb_val in var.load_balancers : [
      for rule in lb_val.rules : {
        lb_key = lb_key
        rule   = rule
      }
    ]
  ])
}

# Creates a Public IP for the Load Balancer frontend
resource "azurerm_public_ip" "this" {
  for_each            = var.load_balancers
  name                = "${each.value.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Creates the Azure Load Balancer
resource "azurerm_lb" "this" {
  for_each            = var.load_balancers
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = each.value.sku

  frontend_ip_configuration {
    name                 = each.value.frontend_ip_configurations[0].name
    public_ip_address_id = azurerm_public_ip.this[each.key].id
  }
}

# Creates the Backend Address Pool
resource "azurerm_lb_backend_address_pool" "this" {
  for_each        = var.load_balancers
  loadbalancer_id = azurerm_lb.this[each.key].id
  name            = "${each.value.name}-backend-pool"
}

# Creates the Load Balancer Rules
resource "azurerm_lb_rule" "this" {
  for_each                       = { for item in local.all_rules : "${item.lb_key}-${item.rule.name}" => item }
  loadbalancer_id                = azurerm_lb.this[each.value.lb_key].id
  name                           = each.value.rule.name
  protocol                       = each.value.rule.protocol
  frontend_port                  = each.value.rule.frontend_port
  backend_port                   = each.value.rule.backend_port
  frontend_ip_configuration_name = azurerm_lb.this[each.value.lb_key].frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this[each.value.lb_key].id]
}

# Associates the VM Network Interfaces with the LB Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "this" {
  # The key of this map is the VM's logical name, and the value is an object containing the NIC ID and the LB key.
  for_each                = var.vm_nic_ids_by_vm_key
  network_interface_id    = each.value.nic_id
  ip_configuration_name   = "internal" # Must match the NIC's IP config name
  # Dynamically look up the backend pool ID based on the key provided from the root module.
  backend_address_pool_id = azurerm_lb_backend_address_pool.this[each.value.lb_key].id
}