output "nsg_ids" {
  description = "A map of the created Network Security Group IDs, keyed by their logical name."
  value       = { for k, v in azurerm_network_security_group.this : k => v.id }
}