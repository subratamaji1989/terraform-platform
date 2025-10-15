variable "resource_group_name" {
  description = "The name of the Azure Resource Group."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "load_balancers" {
  description = "A map of Azure Load Balancer (L4) configurations."
  type = map(object({
    name = string
    sku  = optional(string, "Standard")
    frontend_ip_configurations = list(object({
      name              = string
      public_ip_address = optional(bool, true)
    }))
    rules = list(object({
      name          = string
      protocol      = string
      frontend_port = number
      backend_port  = number
    }))
  }))
}

variable "vm_nic_ids_by_vm_key" {
  description = "A map of objects containing VM NIC IDs and their target load balancer key."
  type = map(object({
    nic_id = string
    lb_key = string
  }))
  default     = {}
}