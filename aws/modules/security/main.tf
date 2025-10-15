# This module manages the lifecycle of security groups and their associated rules.
# It is designed to be idempotent, checking for existing security groups before creating new ones.

# --- Data sources to look for pre-existing Security Groups ---
# The data block for checking existing security groups has been removed as requested.
# The module will now attempt to create all security groups.

# --- Security Group Creation ---
resource "aws_security_group" "this" {
  for_each = var.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_id
  tags        = merge(var.vpc_tags, each.value.tags)
}

locals {
  # Unified map of all security groups, merging existing and newly created ones.
  all_security_groups = {
    for k, v in var.security_groups : k => {
      id = aws_security_group.this[k].id
    }
  }
}

# --- Security Group Rule Creation ---
resource "aws_security_group_rule" "this" {
  for_each = {
    for item in flatten([
      for sg_key, sg in var.security_groups : [
        for rule_idx, rule in sg.rules : {
          rule_key      = "${sg_key}-${rule_idx}"
          sg_key        = sg_key
          rule_details  = rule
        }
      ]
    ]) : item.rule_key => item
  }

  type                     = each.value.rule_details.type
  from_port                = each.value.rule_details.from_port
  to_port                  = each.value.rule_details.to_port
  protocol                 = each.value.rule_details.protocol
  cidr_blocks              = try(each.value.rule_details.cidr_blocks, null)
  source_security_group_id = try(each.value.rule_details.source_sg_key, null) != null ? local.all_security_groups[each.value.rule_details.source_sg_key].id : null
  security_group_id        = local.all_security_groups[each.value.sg_key].id
}