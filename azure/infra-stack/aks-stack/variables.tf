# variables.tf - Input variables for the aks-stack composition

variable "cluster" {
  description = "Object containing AKS cluster configuration."
  type = object({
    name               = string
    kubernetes_version = string
    node_pools = map(object({
      name                = string
      vm_size             = string
      node_count          = number
      min_count           = number
      max_count           = number
      enable_auto_scaling = bool
    }))
  })
}

variable "vnet" {
  description = "Object containing VNet configuration."
  type = object({
    name          = string
    address_space = list(string)
  })
}

variable "subnets" {
  description = "Map of subnets to create."
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
}

variable "app_gateway" {
  description = "Object containing Application Gateway configuration from lb.yaml."
  type = object({
    name          = string
    frontend_port = number
    backend_port  = number
    sku = object({
      name     = string
      tier     = string
      capacity = number
    })
  })
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}