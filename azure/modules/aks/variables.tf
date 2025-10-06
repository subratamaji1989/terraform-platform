# variables.tf - Input variables for the AKS module

variable "resource_group_name" {
  description = "The name of the resource group for the AKS cluster."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created."
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
  description = "The ID of the subnet where the AKS cluster nodes will be deployed."
  type        = string
}

variable "private_cluster_enabled" {
  description = "Whether to create the AKS cluster as a private cluster."
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "The ID of the Private DNS Zone for the private AKS cluster. Required if private_cluster_enabled is true."
  type        = string
  default     = null
}

variable "node_pools" {
  description = "A map of user-defined node pools to create for the AKS cluster."
  type = map(object({
    name                = string
    vm_size             = string
    node_count          = number
    min_count           = number
    max_count           = number
    enable_auto_scaling = bool
  }))
  default = {}
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}