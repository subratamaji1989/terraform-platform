# This module creates the IAM role and EKS cluster resources.

data "aws_caller_identity" "current" {}

# IAM Role for the EKS Cluster Control Plane
resource "aws_iam_role" "cluster" {
  # Create the role if a cluster is defined. Terraform will manage its state.
  count = var.cluster_config != null ? 1 : 0
  name  = "${var.cluster_config.name}-cluster-role"

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

locals {
  # Directly reference the created role.
  cluster_role_arn  = try(aws_iam_role.cluster[0].arn, null)
  cluster_role_name = try(aws_iam_role.cluster[0].name, null)
}

# Attach the required AWS-managed policy to the cluster role.
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  count      = local.cluster_role_name != null ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = local.cluster_role_name
}

# --- EKS Cluster ---
resource "aws_eks_cluster" "main" {
  count    = var.cluster_config != null ? 1 : 0
  name     = var.cluster_config.name
  version  = var.cluster_config.version
  role_arn = local.cluster_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  access_config {
    bootstrap_cluster_creator_admin_permissions = true
    authentication_mode                         = "API_AND_CONFIG_MAP"
  }

  # Note: If you encounter a "no such host" error for the EKS endpoint during creation,
  # it indicates a DNS resolution problem in your CI/CD runner's network environment.
  # Ensure the runner's VPC has DNS resolution enabled and can reach public AWS service endpoints.
  depends_on = [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy]

  lifecycle {
    postcondition {
      condition     = self.status == "ACTIVE"
      error_message = "Post-creation check failed: EKS cluster is not in ACTIVE state."
    }
  }
}