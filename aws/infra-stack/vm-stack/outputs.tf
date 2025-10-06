# Defines the outputs for the app_stack composition.

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = try(module.network[0].vpc_id, module.network.vpc_id, null)
}

output "subnet_ids" {
  description = "A map of the created subnet IDs."
  value       = try(module.network[0].subnet_ids, module.network.subnet_ids, {})
}

output "instance_ids" {
  description = "A map of the created EC2 instance IDs."
  value       = try(module.lb[0].instance_ids, module.lb.instance_ids, {})
}

output "bucket_names" {
  description = "A map of the created S3 bucket names."
  value       = try(module.storage[0].bucket_names, module.storage.bucket_names, {})
}

output "load_balancer_dns" {
  description = "The DNS name of the load balancer."
  value       = try(module.lb[0].load_balancer_dns, module.lb.load_balancer_dns, null)
}

output "load_balancer_arn" {
  description = "The ARN of the load balancer."
  value       = try(module.lb[0].load_balancer_arn, null)
}

output "listener_arns" {
  description = "A map of the created listener ARNs."
  value       = try(module.lb[0].listener_arns, {})
}

output "target_group_arns" {
  description = "A map of the created target group ARNs."
  value       = try(module.lb[0].target_group_arns, {})
}

output "security_group_ids" {
  description = "A map of the created security group IDs."
  value       = { for k, v in aws_security_group.this : k => v.id }
}