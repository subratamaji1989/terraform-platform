# Creates Azure Storage Accounts
resource "azurerm_storage_account" "this" {
  for_each                 = var.storage_accounts
  name                     = "${each.value.name}${var.unique_suffix}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
}