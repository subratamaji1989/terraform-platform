package main

# Helper to find resources of a specific type from the Terraform plan
find_resources(type) = resources {
	resources := [res |
		some res_name
		input.resource_changes[res_name].type == type
		input.resource_changes[res_name].change.after != null
		res := input.resource_changes[res_name]
	]
}