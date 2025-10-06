# Defines the input variables for the EKS module.

variable "cluster_config" {
  description = "Configuration object for the EKS cluster."
  type = object({
    name        = string
    version     = string
    subnet_keys = list(string) # Used by the composition, not directly by this module
    node_groups = map(object({
      instance_types = list(string)
      desired_size   = number
      min_size       = number
      max_size       = number
    }))
  })
}

variable "subnet_ids" {
  description = "A list of actual subnet IDs where the EKS cluster and nodes will be deployed."
  type        = list(string)
}