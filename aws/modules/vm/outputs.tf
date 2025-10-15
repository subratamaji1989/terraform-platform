# Outputs for the VM module
output "instance_ids" {
  description = "A map of the created EC2 instance IDs."
  value       = { for k, v in local.all_instances : k => v.id }
}