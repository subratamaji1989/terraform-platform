variable "load_balancer" {
  description = "Configuration object for the load balancer, typically from a YAML file."
  type = object({
    name               = string
    internal           = optional(bool)
    load_balancer_type = optional(string)
    subnet_keys        = list(string)
    security_groups    = optional(list(string))
    tags               = optional(map(string))
    listeners = map(object({
      port     = number
      protocol = string
      target_group = object({
        name     = string
        port     = number
        protocol = optional(string)
      })
    }))
  })
}

variable "vpc_id" {
  description = "The ID of the VPC where the load balancer will be deployed."
  type        = string
}

variable "security_groups" {
  description = "A list of security group IDs to associate with the load balancer."
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the load balancer will be deployed."
  type        = list(string)
  default     = []
}