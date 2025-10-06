# This composition is dedicated to deploying an EKS cluster and its required networking.

# Network module (deploy if vpc is defined)
module "network" {
  source   = "../../modules/network"
  vpc_cidr = var.vpc.cidr
  vpc_tags = var.vpc.tags
  subnets  = var.subnets
  count    = var.vpc != null ? 1 : 0 # Only create if a VPC is defined
}

# EKS module (deploy if a cluster is defined)
module "eks" {
  source         = "../../modules/eks"
  cluster_config = var.cluster
  # Look up the subnet IDs from the network module using the logical keys from the YAML
  subnet_ids     = [for k in var.cluster.subnet_keys : module.network[0].subnet_ids[k]]
  # Only create if a cluster is defined and a network is available
  count          = var.cluster != null && var.vpc != null ? 1 : 0
}