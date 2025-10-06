# variables.tf - Input variables for the Azure VM module.

variable "resource_group_name" {
  description = "The name of the resource group where VMs will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
}

variable "subnet_ids" {
  description = "A map of logical subnet names to their actual Azure resource IDs."
  type        = map(string)
}

variable "instances" {
  description = "A map of virtual machine configurations to create."
  type = map(object({
    vm_size        = string
    admin_username = string
    subnet_key     = string
    image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    tags = map(string)
  }))
  default = {}
}

variable "admin_public_key" {
  description = "The public SSH key for the admin user."
  type        = string
  sensitive   = true
  default     = null # Make this optional so plans don't fail if no VMs are defined.
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}