# variables.tf - Input variables for the Application Gateway module.

variable "gateway_name" {
  description = "The name of the Application Gateway."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region."
  type        = string
}

variable "gateway_subnet_id" {
  description = "The ID of the subnet dedicated to the Application Gateway."
  type        = string
}

variable "vnet_id" {
  description = "The ID of the Virtual Network where the gateway resides."
  type        = string
}

variable "sku_name" {
  description = "The name of the SKU for the Application Gateway."
  type        = string
}

variable "sku_tier" {
  description = "The tier of the SKU for the Application Gateway."
  type        = string
}

variable "sku_capacity" {
  description = "The capacity of the SKU (number of compute units)."
  type        = number
}

variable "frontend_port" {
  description = "The port for the frontend listener."
  type        = number
}

variable "backend_port" {
  description = "The port for the backend HTTP settings."
  type        = number
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
  default     = {}
}