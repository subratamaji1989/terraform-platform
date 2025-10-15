# This is the main composition file that orchestrates all modules for a unified stack.
# It creates resources conditionally based on the variables provided from the YAML files.

# --- Network Module ---
# Deploys VPC and subnets if a VPC is defined in the variables.
# The module is instantiated only if the 'vpc' variable is not null.
module "network" {
  source = "../modules/network"
  count    = var.vpc != null ? 1 : 0
  vpc_cidr = try(var.vpc.cidr, null)
  vpc_tags = try(var.vpc.tags, null)
  subnets  = try(var.subnets, {})
}

# --- Security Module ---
# Creates security groups. Depends on the VPC from the network module.
module "security" {
  source          = "../modules/security"
  count           = var.security_groups != {} ? 1 : 0
  security_groups = var.security_groups
  vpc_id          = try(module.network[0].vpc_id, null)
  vpc_tags        = try(var.vpc.tags, {})
}

# --- Storage Module ---
# Creates S3 buckets.
module "storage" {
  source  = "../modules/storage"
  count   = var.buckets != {} ? 1 : 0
  buckets = var.buckets
}

# --- ECR Module ---
# Creates ECR repositories.
module "ecr" {
  source       = "../modules/ecr"
  count        = var.repositories != {} ? 1 : 0
  repositories = var.repositories
}

# --- Load Balancer Module ---
# Creates an Application Load Balancer and its components.
module "lb" {
  source          = "../modules/lb"
  count           = var.load_balancer != null ? 1 : 0
  load_balancer   = var.load_balancer
  vpc_id          = try(module.network[0].vpc_id, null)
  subnet_ids      = try([for k in var.load_balancer.subnet_keys : module.network[0].subnet_ids[k]], [])
  security_groups = try([for sg_key in var.load_balancer.security_groups : module.security[0].security_group_ids[sg_key]], [])
}

# --- VM Module ---
# Creates EC2 instances.
module "vm" {
  source        = "../modules/vm"
  count         = var.instances != {} ? 1 : 0
  instances     = var.instances
  subnet_lookup = try(module.network[0].subnet_ids, {})
  sg_lookup     = try(module.security[0].security_group_ids, {})
  vpc_tags      = try(var.vpc.tags, {})
}

# --- EKS Module ---
# Creates an EKS cluster.
module "eks" {
  source         = "../modules/eks"
  count          = var.cluster != null ? 1 : 0
  cluster_config = var.cluster
  subnet_ids     = try([for k in var.cluster.subnet_keys : module.network[0].subnet_ids[k]], [])
}

# --- Target Group Attachments for VMs ---
# This resource links the EC2 instances created by the vm module
# to the target groups created by the lb module.
resource "aws_lb_target_group_attachment" "this" {
  # Create an attachment for each instance that has a 'target_group_key' defined.
  for_each = {
    for i_key, i_val in var.instances : i_key => i_val
    if try(i_val.target_group_key, null) != null
  }

  target_group_arn = try(module.lb[0].target_group_arns[each.value.target_group_key], null)
  target_id        = try(module.vm[0].instance_ids[each.key], null)

  # Explicitly depend on the modules that create the target groups and instances
  # to ensure correct creation and destruction order.
  depends_on = [module.lb, module.vm]
}