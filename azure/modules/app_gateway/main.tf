# main.tf - Defines the Azure Application Gateway resources.

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

  frontend_port {
    name = "http-port"
    port = var.frontend_port
  }

  frontend_ip_configuration {
    name                 = "public-ip-config"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  backend_address_pool {
    name = "default-backend-pool"
    # Backend IPs will be added by the Application Gateway Ingress Controller (AGIC) running in AKS.
  }

  backend_http_settings {
    name                  = "default-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = var.backend_port
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "default-listener"
    frontend_ip_configuration_name = "public-ip-config"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "default-rule"
    rule_type                  = "Basic"
    http_listener_name         = "default-listener"
    backend_address_pool_name  = "default-backend-pool"
    backend_http_settings_name = "default-http-settings"
  }

  # Enable a system-assigned identity for the gateway.
  # This identity will be granted permissions to manage network resources for the AKS cluster.
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Grant the Application Gateway's identity the "Network Contributor" role on the VNet.
# This allows the Application Gateway Ingress Controller (AGIC) to modify network configurations.
resource "azurerm_role_assignment" "agic_vnet_permission" {
  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_application_gateway.app_gateway.identity[0].principal_id
}