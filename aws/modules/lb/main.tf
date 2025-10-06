# Creates the primary Load Balancer resource
resource "aws_lb" "my_lb" {
  name               = var.load_balancer.name
  internal           = try(var.load_balancer.internal, false)
  load_balancer_type = try(var.load_balancer.load_balancer_type, "application")
  security_groups    = var.security_groups
  # Look up the actual subnet IDs from the logical names provided
  subnets            = [for k in var.load_balancer.subnet_keys : var.subnet_lookup[k]]
  tags               = try(var.load_balancer.tags, {})
}

# --- Create Target Groups, Instances, and Attachments for each Listener ---

locals {
  # Flatten the listeners and their nested instances into a single map for easier resource creation.
  # This creates a map where the key is like "http_listener-app_server_1"
  # and the value contains all details for the instance and its target group.
  flattened_instances = {
    for item in flatten([
      for l_key, l_val in var.load_balancer.listeners : [
        for i_key, i_val in l_val.target_group.instances : {
          flat_key         = "${l_key}-${i_key}"
          listener_key     = l_key
          instance_key     = i_key
          instance_details = i_val
          tg_details       = l_val.target_group
        }
      ]
    ]) : item.flat_key => item
  }
}

# Create one Target Group for each listener defined in the lb.yaml
resource "aws_lb_target_group" "main" {
  for_each = var.load_balancer.listeners
  name     = each.value.target_group.name
  port     = each.value.target_group.port
  protocol = try(each.value.target_group.protocol, "HTTP")
  vpc_id   = var.vpc_id

  health_check {
    path = try(each.value.target_group.health_check.path, "/")
  }
}

# Create one Listener for each listener defined in the lb.yaml
resource "aws_lb_listener" "main" {
  for_each          = var.load_balancer.listeners
  load_balancer_arn = aws_lb.my_lb.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[each.key].arn
  }
}

# Create one EC2 Instance for each instance defined under a target group
resource "aws_instance" "vm" {
  for_each               = local.flattened_instances
  ami                    = each.value.instance_details.ami
  instance_type          = each.value.instance_details.instance_type
  subnet_id              = var.subnet_lookup[var.load_balancer.subnet_keys[0]] # Assumes all instances in the first subnet key
  vpc_security_group_ids = [var.sg_lookup["app_sg"]]                             # Assumes all instances use the 'app_sg'
}

# Create one Attachment for each instance, linking it to the correct target group
resource "aws_lb_target_group_attachment" "this" {
  for_each         = local.flattened_instances
  target_group_arn = aws_lb_target_group.main[each.value.listener_key].arn
  target_id        = aws_instance.vm[each.key].id
  port             = each.value.tg_details.port
}