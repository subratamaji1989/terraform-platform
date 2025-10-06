# variables.tf - Input variables for the Azure VM stack composition.

variable "vnet" {
  description = "Object containing VNet configuration from network.yaml."
  type = object({
    name          = string
    address_space = list(string)
  })
}

variable "subnets" {
  description = "Map of subnets to create from network.yaml."
  type = map(object({
    name             = string
    address_prefixes = list(string)
    nsg_key          = optional(string) # The logical key of the NSG to associate from security.yaml
  }))
}

variable "nsgs" {
  description = "A map of Network Security Group configurations from security.yaml."
  type = map(object({
    name  = string
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
  default = {}
}

variable "instances" {
  description = "A map of virtual machine configurations from vm.yaml."
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
  description = "The public SSH key for the admin user on the VMs. This should be passed securely."
  type        = string
  sensitive   = true
  default     = null # Make it optional, only needed if instances are defined.
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}