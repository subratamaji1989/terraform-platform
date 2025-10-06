output "instance_ids" {
  description = "A map of the created EC2 instance IDs, keyed by the logical instance name."
  value       = { for k, v in aws_instance.vm : k => v.id }
}

output "instance_arns" {
  description = "A map of the created EC2 instance ARNs, keyed by the logical instance name."
  value       = { for k, v in aws_instance.vm : k => v.arn }
}