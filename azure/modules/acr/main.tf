# Creates Azure Container Registries
resource "azurerm_container_registry" "this" {
  for_each            = var.container_registries
  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = each.value.sku
  admin_enabled       = true # Enable admin user for simple authentication scenarios
}