# Load Balancer Module Documentation

## Overview

The Load Balancer (LB) module is designed to provision and manage load balancers in AWS. This module supports both Application Load Balancers (ALB) and Network Load Balancers (NLB), allowing for flexible traffic distribution across multiple targets such as EC2 instances, containers, or IP addresses.

## Purpose

The primary purpose of this module is to simplify the creation and management of load balancers, ensuring that they are configured correctly and efficiently. It abstracts the complexity of the underlying AWS resources, providing a user-friendly interface for defining load balancer configurations.

## Usage

To use the Load Balancer module, include it in your Terraform configuration as follows:

```hcl
module "load_balancer" {
  source = "../modules/lb"

  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application" # or "network"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_subnet.id]

  # Additional configuration options
  enable_deletion_protection = false
  tags = {
    Environment = "dev"
    Project     = "my-project"
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