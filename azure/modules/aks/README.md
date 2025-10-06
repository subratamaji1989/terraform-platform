# Azure Kubernetes Service (AKS) Module Documentation

## Overview

The Azure Kubernetes Service (AKS) module is designed to provision and manage a managed Kubernetes cluster in Azure. This module simplifies the creation of an AKS cluster, including its system node pool and additional user-defined node pools for running application workloads.

## Purpose

The primary purpose of this module is to provide a reusable, data-driven way to create AKS clusters. It abstracts the complexity of the underlying Azure resources, providing a user-friendly interface for defining cluster and node pool configurations via input variables.

## Usage

To use the AKS module, include it in your Terraform composition as follows:

```hcl
module "load_balancer" {
  source = "../../modules/aks"

  resource_group_name = "my-aks-rg"
  location            = "East US"
  cluster_name        = "my-aks-cluster"
  kubernetes_version  = "1.28.5"
  vnet_subnet_id      = module.network.subnet_ids["my_aks_subnet"]

  node_pools = {
    workload_pool_1 = {
      name                = "workload1"
      vm_size             = "Standard_D2s_v3"
      node_count          = 2
      min_count           = 1
      max_count           = 3
      enable_auto_scaling = true
    }
  }

  tags = {
    Environment = "dev"
  }
}
```

## Inputs

The module accepts the following input variables:

- `name`: (Required) The name of the load balancer.
- `internal`: (Optional) Boolean flag to specify if the load balancer is internal or external. Default is `false`.
- `load_balancer_type`: (Required) The type of load balancer to create. Accepts `application` or `network`.
- `security_groups`: (Optional) A list of security group IDs to associate with the load balancer.
- `subnets`: (Required) A list of subnet IDs where the load balancer will be deployed.
- `enable_deletion_protection`: (Optional) Boolean flag to enable deletion protection. Default is `false`.
- `tags`: (Optional) A map of tags to assign to the load balancer.

## Outputs

The module provides the following outputs:

- `dns_name`: The DNS name of the load balancer.
- `arn`: The Amazon Resource Name (ARN) of the load balancer.
- `id`: The ID of the load balancer.

## Example

Here is an example of how to use the Load Balancer module in a Terraform configuration:

```hcl
module "my_lb" {
  source = "./modules/lb"

  name               = "my-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_lb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name        = "My Application Load Balancer"
    Environment = "production"
  }
}
```

## Conclusion

This Load Balancer module provides a robust and flexible way to manage load balancers in AWS. By using this module, you can ensure that your load balancer configurations are consistent and adhere to best practices.