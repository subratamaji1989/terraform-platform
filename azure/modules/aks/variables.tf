variable "resource_group_name" {
  description = "The name of the Azure Resource Group."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
}

variable "cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to use for the cluster."
  type        = string
}

variable "vnet_subnet_id" {
  description = "The ID of the subnet to use for the AKS node pools."
  type        = string
}

variable "default_node_pool" {
  description = "Configuration for the default node pool."
  type = object({
    vm_size             = string
    node_count          = number
    min_count           = optional(number)
    max_count           = optional(number)
    enable_auto_scaling = optional(bool, false)
  })
}

variable "node_pools" {
  description = "A map of user node pool configurations."
  type = map(object({
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
  default = {}
}

variable "tags" {
  description = "A map of tags to apply to the cluster and node pools."
  type        = map(string)
  default     = {}
}