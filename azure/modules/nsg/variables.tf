variable "resource_group_name" {
  description = "The name of the Azure Resource Group."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "security_groups" {
  description = "A map of Network Security Group configurations."
  type = map(object({
    name        = string
    subnet_keys = optional(list(string), [])
    rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
}

variable "subnet_ids_by_key" {
  description = "A map of subnet IDs, keyed by their logical name."
  type        = map(string)
}