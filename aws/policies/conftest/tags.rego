package main

import data.main.find_resources

# List of required tags for all resources that support them.
required_tags = {"Environment", "Owner"}

deny[msg] {
	# Find all resources that have a "tags" attribute
	resource := find_resources(_)[_]
	resource.change.after.tags != null

	# Check if any required tags are missing
	missing_tag := required_tags[_]
	not resource.change.after.tags[missing_tag]
	msg := sprintf("Resource '%s' of type '%s' is missing required tag: '%s'", [resource.address, resource.type, missing_tag])
}