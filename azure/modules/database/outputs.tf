output "sql_server_ids" {
  description = "A map of the created SQL Server IDs."
  value       = { for k, v in azurerm_mssql_server.this : k => v.id }
}