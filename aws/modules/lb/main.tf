# Creates the primary Load Balancer resource
resource "aws_lb" "my_lb" {
  # Create the LB if the variable is not null. Terraform will manage its state.
  count              = var.load_balancer != null ? 1 : 0
  name               = var.load_balancer.name
  internal           = try(var.load_balancer.internal, false)
  load_balancer_type = try(var.load_balancer.load_balancer_type, "application")
  security_groups    = var.security_groups
  subnets            = var.subnet_ids
  tags               = try(var.load_balancer.tags, {})

  lifecycle {
    postcondition {
      condition     = self.arn != "" && self.dns_name != ""
      error_message = "Post-creation check failed: Load balancer ARN or DNS name is empty."
    }
  }
}

locals {
  # Directly reference the created load balancer.
  lb_arn = try(aws_lb.my_lb[0].arn, null)
}

# --- Target Groups ---
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

locals {
  # Creates a unified map of all target groups, merging existing and newly created ones.
  all_target_groups = {
    for k, v in var.load_balancer.listeners : k => aws_lb_target_group.main[k].arn
  }
}

# Create one Listener for each listener defined in the lb.yaml
resource "aws_lb_listener" "main" {
  for_each          = var.load_balancer.listeners
  load_balancer_arn = local.lb_arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = local.all_target_groups[each.key]
  }
}

locals {
  # Creates a unified map of all listeners, merging existing and newly created ones.
  all_listeners = {
    for k, v in var.load_balancer.listeners : k => {
      arn = aws_lb_listener.main[k].arn
    }
  }
}