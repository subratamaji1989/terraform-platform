# Defines the input variables for the storage module.

variable "buckets" {
  description = "A map of S3 bucket configurations to create. The keys are logical names for the buckets."
  type = map(object({
    name = string
    tags = map(string)
  }))
  default = {}
}