variable "resource_group_name" {
  description = "The name of the Azure Resource Group."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "storage_accounts" {
  description = "A map of Azure Storage Account configurations."
  type = map(object({
    name                     = string
    account_tier             = string
    account_replication_type = string
  }))
}

variable "unique_suffix" {
  description = "A short, random string to append to storage account names for global uniqueness."
  type        = string
}