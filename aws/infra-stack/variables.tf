# Defines the input variables for the unified_stack composition.
# These variables are populated by the merged YAML files from the app-config repository.

variable "vpc" {
  description = "VPC configuration object. Corresponds to network.yaml."
  type = object({
    cidr = string
    tags = optional(map(string), {})
  })
  default = null
}

variable "subnets" {
  description = "A map of subnet configurations. Corresponds to network.yaml."
  type = map(object({
    cidr_block        = string
    availability_zone = string
    tags              = optional(map(string), {})
  }))
  default = {}
}

variable "buckets" {
  description = "A map of S3 bucket configurations. Corresponds to storage.yaml."
  type = map(object({
    name = string
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "load_balancer" {
  description = "Load balancer configuration. Corresponds to lb.yaml."
  type = object({
    name               = string
    internal           = optional(bool, false)
    load_balancer_type = optional(string, "application")
    security_groups    = list(string)
    subnet_keys        = list(string) # Logical names of subnets from the 'subnets' variable
    tags               = optional(map(string), {})
    listeners = optional(map(object({
      port     = number
      protocol = string
      target_group = optional(object({
        name     = string
        port     = number
        protocol = optional(string, "HTTP")
        health_check = optional(object({
          path = optional(string)
        }), null)
      }), null)
    })), {})
  })
  default = null
}

variable "security_groups" {
  description = "A map of security group configurations to create. Corresponds to security.yaml."
  type = map(object({
    name        = string
    description = optional(string)
    tags        = optional(map(string), {})
    rules = list(object({
      type          = string
      from_port     = number
      to_port       = number
      protocol      = string
      cidr_blocks   = optional(list(string))
      source_sg_key = optional(string) # Logical name of a security group from this variable
    }))
  }))
  default = {}
}

variable "repositories" {
  description = "A map of ECR repository configurations. Corresponds to ecr.yaml."
  type = map(object({
    name                 = string
    image_tag_mutability = string
    scan_on_push         = bool
    tags                 = map(string)
  }))
  default = {}
}

variable "cluster" {
  description = "EKS cluster configuration. Corresponds to eks.yaml."
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

variable "instances" {
  description = "A map of EC2 instance configurations. Corresponds to vm.yaml."
  type = map(object({
    ami                 = string
    instance_type       = string
    subnet_key          = string
    security_group_keys = list(string)
    target_group_key    = optional(string)
    tags                = optional(map(string), {})
  }))
  default = {}
}