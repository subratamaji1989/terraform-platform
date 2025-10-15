output "login_servers" {
  description = "A map of the created container registry login server hostnames."
  value       = { for k, v in azurerm_container_registry.this : k => v.login_server }
}