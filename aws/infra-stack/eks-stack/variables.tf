# Defines the input variables for the EKS stack composition.

variable "vpc" {
  description = "VPC configuration object. Corresponds to network.yaml."
  type = object({
    cidr = string
    tags = map(string)
  })
  default = null
}

variable "cluster" {
  description = "Configuration object for the EKS cluster."
  type = object({
    name        = string
    version     = string
    subnet_keys = list(string)
    node_groups = map(object({
      instance_types = list(string)
      desired_size   = number
      min_size       = number
      max_size       = number
    }))
  })
  default = null
}

variable "subnets" {
  description = "A map of subnets to create. The keys are logical names for the subnets."
  type = map(object({
    cidr_block        = string
    availability_zone = string
    tags              = map(string)
  }))
  default = {}
}