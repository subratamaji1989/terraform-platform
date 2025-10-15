variable "instances" {
  description = "A map of EC2 instance configurations."
  type = map(object({
    ami                 = string
    instance_type       = string
    subnet_key          = string
    security_group_keys = list(string)
    tags                = optional(map(string), {})
  }))
  default = {}
}

variable "subnet_lookup" {
  description = "A map of subnet logical names to their actual AWS subnet IDs."
  type        = map(string)
}

variable "sg_lookup" {
  description = "A map of security group logical names to their actual AWS security group IDs."
  type        = map(string)
}

variable "vpc_tags" {
  description = "Tags from the VPC to merge with instance tags."
  type        = map(string)
  default     = {}
}