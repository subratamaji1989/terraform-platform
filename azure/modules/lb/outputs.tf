output "public_ip_addresses" {
  description = "A map of public IP addresses for the created Load Balancers."
  value       = { for k, v in azurerm_public_ip.this : k => v.ip_address }
}