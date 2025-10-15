output "network_interface_ids" {
  description = "The ID of the network interface for the virtual machine."
  value       = azurerm_network_interface.this.id
}