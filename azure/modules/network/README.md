# Network Module Documentation

## Overview

The Network module is designed to provision and manage networking resources in AWS using Terraform. This module includes the creation of Virtual Private Clouds (VPCs), subnets, route tables, and other essential networking components required for deploying applications in a secure and scalable manner.

## Purpose

This module simplifies the process of setting up the network infrastructure by providing reusable Terraform configurations. It allows users to define their networking requirements through input variables and outputs essential information for other modules.

## Usage

To use the Network module, include it in your Terraform configuration as follows:

```hcl
module "network" {
  source = "../modules/network"

  # Input variables
  vpc_cidr = "10.0.0.0/16"
  subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  tags = {
    Name = "MyVPC"
  }
}
```

## Inputs

The module accepts the following input variables:

- `vpc_cidr`: The CIDR block for the VPC.
- `subnet_cidrs`: A list of CIDR blocks for the subnets.
- `tags`: A map of tags to assign to the resources.

## Outputs

The module provides the following outputs:

- `vpc_id`: The ID of the created VPC.
- `subnet_ids`: A list of IDs of the created subnets.

## Example

Here is an example of how to use the Network module in a Terraform configuration:

```hcl
provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "./modules/network"

  vpc_cidr = "10.0.0.0/16"
  subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  tags = {
    Name = "MyVPC"
  }
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "subnet_ids" {
  value = module.network.subnet_ids
}
```

## Conclusion

The Network module is a crucial component for setting up the foundational networking infrastructure in AWS. By using this module, users can ensure that their network is configured correctly and consistently across different environments.