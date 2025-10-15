# Defines the outputs for the security module.

output "security_group_ids" {
  description = "A map of all security group IDs, keyed by their logical name."
  value       = { for k, v in local.all_security_groups : k => v.id }
}