variable "resource_group_name" {
  description = "The name of the Azure Resource Group."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "name" {
  description = "The name of the Virtual Machine."
  type        = string
}

variable "size" {
  description = "The size (SKU) of the Virtual Machine."
  type        = string
}

variable "admin_username" {
  description = "The admin username for the Virtual Machine."
  type        = string
}

variable "admin_public_key" {
  description = "The SSH public key for the admin user."
  type        = string
  nullable    = true
}

variable "admin_password" {
  description = "The admin password for the Virtual Machine. Used if no public key is provided."
  type        = string
  nullable    = true
}

variable "image" {
  description = "The source image for the virtual machine."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  nullable = true
}

variable "subnet_ids" {
  description = "A list of subnet IDs to associate with the VM's network interface."
  type        = list(string)
}

variable "network_security_group_id" {
  description = "The ID of the Network Security Group to associate with the VM's network interface."
  type        = string
  nullable    = true
}