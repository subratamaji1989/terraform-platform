output "load_balancer_dns" {
  value = aws_lb.my_lb.dns_name
}

output "load_balancer_arn" {
  value = aws_lb.my_lb.arn
}

output "load_balancer_id" {
  value = aws_lb.my_lb.id
}

output "instance_ids" {
  description = "A map of the created EC2 instance IDs, keyed by their flattened unique key (e.g., 'listener-instance')."
  value       = { for k, v in aws_instance.vm : k => v.id }
}

output "instance_arns" {
  description = "A map of the created EC2 instance ARNs, keyed by their flattened unique key."
  value       = { for k, v in aws_instance.vm : k => v.arn }
}

output "listener_arns" {
  description = "A map of the created listener ARNs."
  value       = { for k, v in aws_lb_listener.main : k => v.arn }
}

output "target_group_arns" {
  description = "A map of the created target group ARNs."
  value       = { for k, v in aws_lb_target_group.main : k => v.arn }
}