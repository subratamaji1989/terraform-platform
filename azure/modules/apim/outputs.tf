output "gateway_urls" {
  description = "A map of the created API Management gateway URLs."
  value       = { for k, v in azurerm_api_management.this : k => v.gateway_url }
}