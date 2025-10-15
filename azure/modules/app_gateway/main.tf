# main.tf - Defines the Azure Application Gateway resources.

locals {
  # Create a flattened list of all associations needed between VM NICs and backend pools.
  # Each item will represent one VM being added to one backend pool.
  all_backend_associations = flatten([
    # For each backend pool defined for this gateway...
    for pool_key, pool_val in var.backend_pools : [
      # For each VM key listed in that pool's backend_vm_keys...
      for vm_key in pool_val.backend_vm_keys : {
        pool_key = pool_key
        vm_key   = vm_key
        nic_id   = var.vm_nic_ids_by_key[vm_key]
      } if lookup(var.vm_nic_ids_by_key, vm_key, null) != null # Ensure the VM NIC exists
    ]
  ])
}

# Create a Public IP address for the Application Gateway.
resource "azurerm_public_ip" "pip" {
  name                = "${var.gateway_name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Create the Application Gateway.
resource "azurerm_application_gateway" "app_gateway" {
  name                = var.gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.sku_capacity
  }

  gateway_ip_configuration {
    name      = "app-gateway-ip-config"
    subnet_id = var.gateway_subnet_id
  }

  frontend_ip_configuration {
    name                 = "public-ip-config"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  dynamic "frontend_port" {
    for_each = var.listeners
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_pools
    content {
      name = backend_address_pool.value.name
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.http_settings
    content {
      name                  = backend_http_settings.value.name
      cookie_based_affinity = "Disabled"
      port                  = backend_http_settings.value.port
      protocol              = backend_http_settings.value.protocol
      path                  = backend_http_settings.value.path
      request_timeout       = 20
    }
  }

  dynamic "http_listener" {
    for_each = var.listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = "public-ip-config"
      frontend_port_name             = http_listener.value.name
      protocol                       = http_listener.value.protocol
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.routing_rules
    content {
      name                       = request_routing_rule.value.name
      priority                   = request_routing_rule.value.priority
      rule_type                  = "Basic"
      http_listener_name         = var.listeners[request_routing_rule.value.listener_key].name
      backend_address_pool_name  = var.backend_pools[request_routing_rule.value.backend_pool_key].name
      backend_http_settings_name = var.http_settings[request_routing_rule.value.http_setting_key].name
    }
  }

  tags = var.tags
}

# Associates the VM Network Interfaces with the Application Gateway Backend Pool
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "this" {
  for_each                = { for item in local.all_backend_associations : "${item.pool_key}-${item.vm_key}" => item }
  network_interface_id    = each.value.nic_id
  ip_configuration_name   = "ipconfig-0" # Must match the NIC's IP config name
  backend_address_pool_id = azurerm_application_gateway.app_gateway.backend_address_pool[index(keys(var.backend_pools), each.value.pool_key)].id
}
