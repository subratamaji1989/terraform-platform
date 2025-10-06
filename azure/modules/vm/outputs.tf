# outputs.tf - Outputs from the Azure VM module.

output "vm_ids" {
  description = "A map of VM names to their resource IDs."
  value       = { for k, v in azurerm_linux_virtual_machine.vm : k => v.id }
}

output "vm_private_ip_addresses" {
  description = "A map of VM names to their private IP addresses."
  value       = { for k, v in azurerm_network_interface.nic : k => v.private_ip_address }
}