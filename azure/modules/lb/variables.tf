variable "load_balancer" {
  description = "Configuration object for the load balancer, typically from a YAML file."
  type = object({
    name               = string
    internal           = optional(bool)
    load_balancer_type = optional(string)
    subnet_keys        = list(string)
    tags               = optional(map(string))
    security_groups    = optional(list(string))
    listeners = map(object({
      port             = number
      protocol         = string
      target_group = object({
        name     = string
        port     = number
        protocol = optional(string)
        health_check = optional(object({
          path = optional(string)
        }))
        instances = map(object({
          instance_type = string
          ami           = string
        }))
      })
    }))
  })
}

variable "vpc_id" {
  description = "The ID of the VPC where the load balancer will be deployed."
  type        = string
}

variable "subnet_lookup" {
  description = "A map of subnet logical names to their actual AWS subnet IDs."
  type        = map(string)
}

variable "security_groups" {
  description = "A list of security group IDs to associate with the load balancer."
  type        = list(string)
  default     = []
}

variable "sg_lookup" {
  description = "A map of security group logical names to their actual AWS security group IDs."
  type        = map(string)
  default     = {}
}