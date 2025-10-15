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

variable "listeners" {
  description = "A map of listener configurations for the Application Gateway."
  type = map(object({
    name     = string
    # The name of the backend pool
    protocol = string
    port     = number
  }))
  default = {}
}

variable "backend_pools" {
  description = "A map of backend address pool configurations."
  type = map(object({
    name = string
    backend_vm_keys = optional(list(string), [])
  }))
  default = {}
}

variable "http_settings" {
  description = "A map of backend HTTP setting configurations."
  type = map(object({
    name     = string
    protocol = string
    port     = number
    path     = optional(string, "/")
  }))
  default = {}
}

variable "routing_rules" {
  description = "A map of request routing rule configurations."
  type = map(object({
    name             = string
    priority         = number
    listener_key     = string
    backend_pool_key = string
    http_setting_key = string
  }))
  default = {}
}

variable "vm_nic_ids_by_key" {
  description = "A map of all VM network interface IDs, keyed by the VM's logical name."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
  default     = {}
}