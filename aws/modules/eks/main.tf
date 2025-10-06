# This module uses the high-level terraform-aws-modules/eks module for simplicity and best practices.

data "aws_caller_identity" "current" {}

# IAM Role for the EKS Cluster Control Plane
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_config.name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 19.0" # Pin to a major version for stability

#   cluster_name         = var.cluster_config.name
#   cluster_version      = var.cluster_config.version
#   cluster_iam_role_arn = aws_iam_role.cluster.arn

#   subnet_ids = var.subnet_ids

#   depends_on = [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy]

#   eks_managed_node_groups = {
#     for name, group in var.cluster_config.node_groups : name => {
#       instance_types = group.instance_types
#       min_size       = group.min_size
#       max_size       = group.max_size
#       desired_size   = group.desired_size
#     }
#   }

#   tags = {
#     Environment = "dev" # Example tag
#   }
# }