package main

import data.main.find_resources

# Deny security group rules that allow unrestricted ingress from the internet.
deny[msg] {
	# Find all AWS security group rule resources
	rule := find_resources("aws_security_group_rule")[_]

	# Check for ingress rules from any IP on a sensitive port
	rule.change.after.type == "ingress"
	rule.change.after.cidr_blocks[_] == "0.0.0.0/0"

	# List of sensitive ports to check
	sensitive_ports := {22, 3389}
	sensitive_ports[rule.change.after.from_port]

	msg := sprintf("Resource '%s' allows unrestricted ingress on a sensitive port (%d).", [rule.address, rule.change.after.from_port])
}