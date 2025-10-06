resource "aws_s3_bucket" "this" {
  for_each = var.buckets
  bucket   = each.value.name
  tags     = each.value.tags

  lifecycle {
    # This value cannot be a variable. It must be a literal true or false.
    # Set to 'true' for production buckets to prevent accidental deletion.
    # For dev/test environments, 'false' is acceptable.
    prevent_destroy = false
  }
}