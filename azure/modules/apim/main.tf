# Creates Azure API Management services
resource "azurerm_api_management" "this" {
  for_each            = var.apim_services
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = each.value.publisher_name
  publisher_email     = each.value.publisher_email
  sku_name            = each.value.sku_name
}