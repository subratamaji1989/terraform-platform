# Module outputs for ECR.

output "repository_urls" {
  description = "A map of the created ECR repository URLs."
  value       = { for k, v in aws_ecr_repository.this : k => v.repository_url }
}