# Defines the outputs for the unified Azure stack.

output "vnet_id" {
  description = "The ID of the created Virtual Network."
  value       = try(module.network[0].vnet_id, null)
}

output "aks_cluster_name" {
  description = "The name of the created AKS cluster."
  value       = try(module.aks[0].cluster_name, null)
}

output "storage_account_ids" {
  description = "A map of the created storage account IDs."
  value       = try(module.storage[0].storage_account_ids, {})
}

output "acr_login_servers" {
  description = "A map of the created container registry login server hostnames."
  value       = try(module.acr[0].login_servers, {})
}

output "sql_server_ids" {
  description = "A map of the created SQL Server IDs."
  value       = try(module.database[0].sql_server_ids, {})
}

output "app_gateway_ids" {
  description = "A map of the created Application Gateway IDs."
  value       = try(module.app_gateway[0].app_gateway_ids, {})
}

output "apim_gateway_urls" {
  description = "A map of the created API Management gateway URLs."
  value       = try(module.apim[0].gateway_urls, {})
}

output "lb_public_ips" {
  description = "A map of public IP addresses for the created Load Balancers."
  value       = try(module.lb[0].public_ip_addresses, {})
}