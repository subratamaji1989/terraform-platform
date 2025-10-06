# Storage Module Documentation

## Overview

The storage module is designed to manage AWS S3 buckets and associated resources. It provides a reusable and configurable way to create and manage storage solutions within your AWS infrastructure.

## Purpose

This module allows users to define S3 buckets with various configurations, including lifecycle rules, versioning, and access policies. It abstracts the complexity of S3 resource management, enabling users to focus on their application logic.

## Usage

To use the storage module, include it in your Terraform configuration as follows:

```hcl
module "storage" {
  source = "../modules/storage"

  bucket_name = "my-unique-bucket-name"
  versioning  = true
  lifecycle_rules = [
    {
      id      = "expire-old-versions"
      enabled = true
      expiration = {
        days = 30
      }
    }
  ]
}
```

## Inputs

| Name          | Description                          | Type   | Default | Required |
|---------------|--------------------------------------|--------|---------|----------|
| bucket_name   | The name of the S3 bucket.          | string | n/a     | yes      |
| versioning    | Enable versioning for the bucket.   | bool   | false   | no       |
| lifecycle_rules | List of lifecycle rules for the bucket. | list(object) | [] | no |

## Outputs

| Name          | Description                          |
|---------------|--------------------------------------|
| bucket_id     | The ID of the created S3 bucket.    |
| bucket_arn    | The ARN of the created S3 bucket.   |
| bucket_domain | The domain name of the S3 bucket.    |

## Example

Here is an example of how to use the storage module in a Terraform configuration:

```hcl
module "storage" {
  source = "../modules/storage"

  bucket_name = "my-example-bucket"
  versioning  = true
  lifecycle_rules = [
    {
      id      = "delete-old-versions"
      enabled = true
      expiration = {
        days = 90
      }
    }
  ]
}
```

## Notes

- Ensure that the bucket name is globally unique across all AWS accounts.
- Review AWS S3 best practices for security and performance when configuring your buckets.

This README provides a comprehensive guide to using the storage module effectively within your AWS infrastructure.