# VM Module Documentation

## Overview

The VM module is designed to provision and manage virtual machine resources in AWS using Terraform. This module simplifies the creation of EC2 instances and associated resources such as EBS volumes.

## Purpose

This module allows users to define the configuration for virtual machines, including instance types, AMI IDs, and networking settings. It abstracts the complexity of managing EC2 instances and provides a reusable component for application stacks.

## Usage

To use the VM module, include it in your Terraform configuration as follows:

```hcl
module "vm" {
  source = "../modules/vm"

  instance_count = 2
  instance_type  = "t3.medium"
  ami_id         = "ami-0abcdef1234567890"
  subnet_id      = module.network.subnet_id
  tags = {
    Name = "MyVM"
  }
}
```

## Inputs

| Name            | Description                          | Type          | Default       |
|-----------------|--------------------------------------|---------------|---------------|
| instance_count  | Number of EC2 instances to create    | `number`      | `1`           |
| instance_type   | Type of EC2 instance                  | `string`      | `t3.micro`    |
| ami_id          | AMI ID for the EC2 instance          | `string`      |               |
| subnet_id       | Subnet ID where the instance will be launched | `string` |               |
| tags            | A map of tags to assign to the instance | `map(string)` | `{}`          |

## Outputs

| Name            | Description                          |
|-----------------|--------------------------------------|
| instance_ids    | List of created EC2 instance IDs     |
| public_ips      | List of public IPs assigned to the instances |

## Example

Here is an example of how to use the VM module in a Terraform configuration:

```hcl
module "vm" {
  source = "../modules/vm"

  instance_count = 2
  instance_type  = "t3.medium"
  ami_id         = "ami-0abcdef1234567890"
  subnet_id      = "subnet-0abcd1234efgh5678"
  tags = {
    Name = "MyAppInstance"
  }
}
```

## Notes

- Ensure that the specified AMI ID is available in the region where you are deploying the instances.
- The module can be extended to include additional resources such as security groups or IAM roles as needed.