# Outputs for the Load Balancer module

output "lb_arn" {
  description = "The ARN of the load balancer."
  value       = local.lb_arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = try(aws_lb.my_lb[0].dns_name, null)
}

output "target_group_arns" {
  description = "A map of target group ARNs, keyed by listener name."
  value       = local.all_target_groups
}

output "listener_arns" {
  description = "A map of listener ARNs, keyed by listener name."
  value       = { for k, v in local.all_listeners : k => v.arn }
}