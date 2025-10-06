# This is the main composition file that orchestrates all modules.
# It creates resources conditionally based on the variables provided from the YAML files.

locals {
  # Use a single network module instance for dependencies, making it more robust.
  network_module = length(module.network) > 0 ? module.network[0] : null
}

# Network module (deploy if vpc is defined)
module "network" {
  source   = "../../modules/network"
  count    = var.vpc != null ? 1 : 0

  vpc_cidr = var.vpc.cidr
  vpc_tags = var.vpc.tags
  subnets  = var.subnets
}

# --- Security Group Creation ---
resource "aws_security_group" "this" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = local.network_module.vpc_id
  tags        = merge(var.vpc.tags, each.value.tags)
}

resource "aws_security_group_rule" "this" {
  # Flatten the nested rules from all security groups into a single map for for_each
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
  source_security_group_id = try(each.value.rule_details.source_sg_key, null) != null ? aws_security_group.this[each.value.rule_details.source_sg_key].id : null
  security_group_id        = aws_security_group.this[each.value.sg_key].id
}

# Storage module (deploy if buckets are defined)
module "storage" {
  source  = "../../modules/storage"
  count   = var.buckets != null && length(var.buckets) > 0 ? 1 : 0
  buckets = var.buckets
}

# Load Balancer module (deploy if load_balancer and target_groups are defined)
module "lb" {
  source        = "../../modules/lb"
  count         = var.load_balancer != null ? 1 : 0

  load_balancer = var.load_balancer
  vpc_id        = local.network_module.vpc_id
  subnet_lookup = local.network_module.subnet_ids
  security_groups = [for sg_key in var.load_balancer.security_groups : aws_security_group.this[sg_key].id]
  sg_lookup     = { for k, v in aws_security_group.this : k => v.id }
}