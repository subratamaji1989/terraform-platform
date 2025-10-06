# outputs.tf - Defines the outputs for the Azure VM stack composition.

output "resource_group_name" {
  description = "The name of the resource group for the VM stack."
  value       = module.network.resource_group_name
}

output "subnet_ids" {
  description = "A map of the created subnet IDs."
  value       = module.network.subnet_ids
}

output "instance_ids" {
  description = "A map of the created Azure VM instance IDs."
  value       = module.vm.vm_ids
}

output "instance_private_ips" {
  description = "A map of the private IP addresses for the created Azure VMs."
  value       = module.vm.vm_private_ip_addresses
}

output "security_group_ids" {
  description = "A map of the created security group IDs."
  value       = { for k, v in azurerm_network_security_group.nsg : k => v.id }
}