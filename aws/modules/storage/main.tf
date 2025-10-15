# --- Data sources to look for pre-existing S3 Buckets ---
data "aws_s3_bucket" "existing" {
  for_each = { for k, v in var.buckets : k => v }
  bucket   = each.value.name
}

# Creates one or more S3 buckets based on the 'buckets' map variable.
resource "aws_s3_bucket" "this" {
  # Only create a bucket if it was not found by the data source lookup.
  for_each = { for k, v in var.buckets : k => v if try(data.aws_s3_bucket.existing[k].id, null) == null }
  bucket   = each.value.name
  tags     = each.value.tags

  lifecycle {
    prevent_destroy = false
  }
}

locals {
  # This local variable creates a unified map of all S3 buckets.
  # It merges the buckets found by the data source with the new ones created by the resource block.
  all_buckets = {
    for k, v in var.buckets : k => {
      id                 = try(data.aws_s3_bucket.existing[k].id, aws_s3_bucket.this[k].id, null)
      arn                = try(data.aws_s3_bucket.existing[k].arn, aws_s3_bucket.this[k].arn, null)
      name               = v.name
      bucket_domain_name = try(data.aws_s3_bucket.existing[k].bucket_domain_name, aws_s3_bucket.this[k].bucket_domain_name, null)
    }
  }
}