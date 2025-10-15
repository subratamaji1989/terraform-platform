# Creates a flattened list of all databases from all servers for easier iteration.
locals {
  all_databases = flatten([
    for server_key, server_val in var.sql_servers : [
      for db_key, db_val in server_val.databases : {
        server_key = server_key
        db_key     = db_key
        db_val     = db_val
      }
    ]
  ])
}

# Creates Azure SQL Servers
resource "azurerm_mssql_server" "this" {
  for_each                     = nonsensitive(var.sql_servers)
  name                         = each.value.name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = each.value.administrator_login
  administrator_login_password = each.value.administrator_login_password
}

# Creates Azure SQL Databases within the servers
resource "azurerm_mssql_database" "this" {
  for_each  = { for item in nonsensitive(local.all_databases) : "${item.server_key}-${item.db_key}" => item }
  name      = each.value.db_val.name
  server_id = azurerm_mssql_server.this[each.value.server_key].id
  sku_name  = each.value.db_val.sku_name
}