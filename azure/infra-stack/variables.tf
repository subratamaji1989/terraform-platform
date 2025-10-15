# Defines the input variables for the unified Azure stack composition.

variable "rg" {
  description = "A map of resource group configurations. Corresponds to rg.yaml."
  type = map(object({
    name     = string
    location = string
    tags     = optional(map(string), {})
  }))
  # The variable is now named 'rg' in the tfvars file.
  # This is just an internal name within the stack.
}

variable "vnet" {
  description = "Virtual Network configuration object. Corresponds to network.yaml."
  type = object({
    name          = string
    address_space = list(string)
    tags          = optional(map(string), {})
  })
  default = null
}

variable "subnets" {
  description = "A map of subnet configurations."
  type = map(object({
    name           = string
    address_prefixes = list(string)
  }))
  default = {}
}

variable "nsgs" {
  description = "A map of Network Security Group configurations. Corresponds to security.yaml."
  type = map(object({
    name        = string
    subnet_keys = optional(list(string), []) # Subnets to associate this NSG with
    rules = list(object({
      name                     = string
      priority                 = number
      direction                = string
      access                   = string
      protocol                 = string
      source_port_range        = string
      destination_port_range   = string
      source_address_prefix    = string
      destination_address_prefix = string
    }))
  }))
  default = {}
}

variable "storage_accounts" {
  description = "A map of Azure Storage Account configurations."
  type = map(object({
    name                     = string
    account_tier             = string
    account_replication_type = string
    unique_suffix            = optional(string) # Injected by the root module
  }))
  default = {}
}

variable "container_registries" {
  description = "A map of Azure Container Registry configurations."
  type = map(object({
    name = string
    sku  = string
  }))
  default = {}
}

variable "sql_servers" {
  description = "A map of Azure SQL Server configurations."
  type = map(object({
    name                         = string
    administrator_login          = string
    administrator_login_password = string # Should be sourced from a secure location like Key Vault
    databases = map(object({
      name     = string
      sku_name = string
    }))
  }))
  default = {}
}

variable "application_gateways" {
  description = "A map of Azure Application Gateway (L7) configurations."
  type = map(object({
    name         = string
    sku_name     = string
    sku_tier     = string
    sku_capacity = number
    subnet_key   = string # Logical key for the gateway's subnet

    listeners = map(object({
      name     = string
      protocol = string
      port     = number
    }))

    backend_pools = map(object({
      name = string
      backend_vm_keys = optional(list(string), []) # Logical keys of VMs to add to this pool
    }))

    http_settings = map(object({
      name     = string
      protocol = string
      port     = number
      path     = optional(string, "/")
    }))

    routing_rules = map(object({
      name             = string
      priority         = number
      listener_key     = string # Logical key to a listener in this gateway
      backend_pool_key = string # Logical key to a backend pool
      http_setting_key = string # Logical key to an http_setting
    }))
  }))
  default = {}
}

variable "api_management_services" {
  description = "A map of API Management service configurations."
  type = map(object({
    name              = string
    publisher_name    = string
    publisher_email   = string
    sku_name          = string
  }))
  default = {}
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
  default = {}
}

variable "cluster" {
  description = "AKS cluster configuration object. Corresponds to eks.yaml."
  type = object({
    name          = string
    kubernetes_version = string
    subnet_keys   = list(string)
    default_node_pool = object({
      vm_size             = string
      node_count          = number
      min_count           = optional(number, null)
      max_count           = optional(number, null)
      enable_auto_scaling = optional(bool, false)
    })
    node_pools = map(object({
      name                = string
      vm_size             = string
      node_count          = number
      min_count           = optional(number, null)
      max_count           = optional(number, null)
      enable_auto_scaling = optional(bool, false)
      availability_zones  = optional(list(string), null)
      mode                = optional(string, "User")
      os_disk_size_gb     = optional(number, null)
      os_type             = optional(string, "Linux")
      priority            = optional(string, "Regular")
      node_labels         = optional(map(string), {})
      tags                = optional(map(string), {})
    }))
  })
  default = null
}

variable "vm" {
  description = "A map of Azure Virtual Machine configurations. Corresponds to vm.yaml."
  type = map(object({
    name          = string
    size          = string
    subnet_key    = string
    nsg_key       = optional(string)
    load_balancer_key = optional(string) # The logical key of the LB to attach this VM to
    admin_username = string
    admin_public_key = optional(string)
    admin_password   = optional(string)
    image = optional(object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    }))
  }))
  default = {}
}

variable "tags" {
  description = "A map of default tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "admin_public_key" {
  description = "The SSH public key for the admin user on VMs."
  type        = string
  default     = null
}