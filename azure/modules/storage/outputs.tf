output "storage_account_ids" {
  description = "A map of the created storage account IDs."
  value       = { for k, v in azurerm_storage_account.this : k => v.id }
}