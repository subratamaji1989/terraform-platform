# outputs.tf - Outputs from the network module

output "resource_group_name" {
  description = "The name of the created resource group."
  value       = azurerm_resource_group.network_rg.name
}

output "vnet_id" {
  description = "The ID of the created Virtual Network."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the created Virtual Network."
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_ids" {
  description = "A map of subnet names to their IDs."
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}