# Defines the input variables for the network module.

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "vpc_tags" {
  description = "A map of tags to assign to the VPC."
  type        = map(string)
  default     = {}
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