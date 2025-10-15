# Defines the input variables for the security module.

variable "security_groups" {
  description = "A map of security group configurations to create."
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

variable "vpc_id" {
  description = "The ID of the VPC where the security groups will be created."
  type        = string
}

variable "vpc_tags" {
  description = "Tags from the VPC to merge with security group tags."
  type        = map(string)
  default     = {}
}