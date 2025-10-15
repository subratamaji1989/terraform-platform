# Outputs for the Storage module

output "bucket_names" {
  description = "A map of the S3 bucket names, keyed by their logical name."
  value       = { for k, v in local.all_buckets : k => v.name }
}

output "bucket_arn" {
  description = "A map of the S3 bucket ARNs, keyed by their logical name."
  value       = { for k, v in local.all_buckets : k => v.arn }
}

output "bucket_domain_name" {
  description = "A map of the S3 bucket domain names, keyed by their logical name."
  value       = { for k, v in local.all_buckets : k => v.bucket_domain_name }
}