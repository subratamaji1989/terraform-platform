# Defines the input variables for the ECR module.

variable "repositories" {
  description = "A map of ECR repository configurations."
  type = map(object({
    name                 = string
    image_tag_mutability = string
    scan_on_push         = bool
    tags                 = map(string)
  }))
  default = {}
}