output "bucket_names" {
  value = { for k, v in aws_s3_bucket.this : k => v.id }
}

output "bucket_arn" {
  value = { for k, v in aws_s3_bucket.this : k => v.arn }
}

output "bucket_domain_name" {
  value = { for k, v in aws_s3_bucket.this : k => v.bucket_domain_name }
}