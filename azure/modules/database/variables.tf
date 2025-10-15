variable "resource_group_name" {
  description = "The name of the Azure Resource Group."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "sql_servers" {
  description = "A map of Azure SQL Server configurations."
  type = map(object({
    name                         = string
    administrator_login          = string
    administrator_login_password = string
    databases = map(object({
      name     = string
      sku_name = string
    }))
  }))
  sensitive = true
}