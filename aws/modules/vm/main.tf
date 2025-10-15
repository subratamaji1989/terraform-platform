# --- Data sources to look for pre-existing EC2 Instances ---
data "aws_instances" "existing" {
  # Look for any instances that have one of the Name tags we are managing.
  filter {
    name   = "tag:Name"
    values = [for i in var.instances : i.tags.Name if try(i.tags.Name, null) != null]
  }
}

# Create a map of existing instance names to their IDs for easy lookup.
locals {
  existing_instance_name_to_id = {
    for id in data.aws_instances.existing.ids :
    data.aws_instance.by_id[id].tags.Name => id
  }
}

# Creates one or more EC2 instances based on the 'instances' map variable
resource "aws_instance" "this" {
  # Only create an instance if it was not found by the data source lookup.
  for_each = {
    for k, v in var.instances : k => v
    if try(local.existing_instance_name_to_id[v.tags.Name], null) == null
  }
  ami           = each.value.ami
  instance_type = each.value.instance_type

  # Look up the subnet ID and security group IDs from the provided maps
  subnet_id              = var.subnet_lookup[each.value.subnet_key]
  vpc_security_group_ids = [for sg_key in each.value.security_group_keys : var.sg_lookup[sg_key]]

  # Merge VPC tags with instance-specific tags
  tags = merge(var.vpc_tags, each.value.tags)
}

locals {
  # This local variable creates a unified map of all instances, merging existing and newly created ones.
  all_instances = {
    for k, v in var.instances : k => {
      id = coalesce(try(local.existing_instance_name_to_id[v.tags.Name], null), try(aws_instance.this[k].id, null))
    }
  }
}

# Helper data source to get details for each existing instance by its ID.
data "aws_instance" "by_id" {
  for_each    = toset(data.aws_instances.existing.ids)
  instance_id = each.key
}