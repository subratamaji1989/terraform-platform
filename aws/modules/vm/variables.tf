variable "instances" {
  description = "A map of EC2 instance configurations. The keys are logical names for the instances."
  type = map(object({
    ami           = string
    instance_type = string
    subnet_key    = string # Logical name of the subnet from the 'subnets' variable
    tags          = optional(map(string), {})
    security_group_keys = list(string) # Logical names of security groups
  }))
  default = {}
}

variable "subnet_lookup" {
  description = "A map of subnet logical names to their actual AWS subnet IDs. This is provided by the network module."
  type        = map(string)
  default     = {}
}

variable "sg_lookup" {
  description = "A map of security group logical names to their actual AWS security group IDs."
  type        = map(string)
  default     = {}
}