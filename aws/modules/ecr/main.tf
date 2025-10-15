# Creates one or more ECR repositories based on the 'repositories' map variable.
resource "aws_ecr_repository" "this" {
  for_each             = var.repositories
  name                 = each.value.name
  image_tag_mutability = each.value.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }
  tags = each.value.tags
}