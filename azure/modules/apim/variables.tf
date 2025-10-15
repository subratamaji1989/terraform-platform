variable "resource_group_name" {
  description = "The name of the Azure Resource Group."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "apim_services" {
  description = "A map of API Management service configurations."
  type = map(object({
    name            = string
    publisher_name  = string
    publisher_email = string
    sku_name        = string
  }))
}