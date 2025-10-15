# Defines the outputs for the unified_stack composition.

output "vpc_id" {
  description = "The ID of the VPC."
  value       = try(module.network[0].vpc_id, null)
}

output "subnet_ids" {
  description = "A map of the created subnet IDs."
  value       = try(module.network[0].subnet_ids, {})
}

output "instance_ids" {
  description = "A map of the created EC2 instance IDs."
  value       = try(module.vm[0].instance_ids, {})
}

output "bucket_names" {
  description = "A map of the created S3 bucket names."
  value       = try(module.storage[0].bucket_names, {})
}

output "load_balancer_dns" {
  description = "The DNS name of the load balancer."
  value       = try(module.lb[0].lb_dns_name, null)
}

output "load_balancer_arn" {
  description = "The ARN of the load balancer."
  value       = try(module.lb[0].lb_arn, null)
}

output "ecr_repository_urls" {
  description = "A map of the created ECR repository URLs."
  value       = try(module.ecr[0].repository_urls, {})
}

output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = try(module.eks[0].cluster_name, null)
}