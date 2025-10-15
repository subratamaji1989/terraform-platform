# Creates the Virtual Private Cloud (VPC)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = var.vpc_tags
}

# Creates one or more subnets based on the 'subnets' map variable
resource "aws_subnet" "main" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone
  # All subnets created here will have public IP mapping enabled.
  # For private subnets, you could add a flag in the YAML and use a conditional here.
  map_public_ip_on_launch = true
  tags              = each.value.tags
}

# Creates an Internet Gateway to allow communication with the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { for k, v in var.vpc_tags : k => v if k == "Name" || k == "Environment" } # Re-use Name/Env tags
}

# Creates a single main route table for the VPC
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { for k, v in var.vpc_tags : k => v if k == "Name" || k == "Environment" } # Re-use Name/Env tags
}

# Creates a route in the route table that directs internet-bound traffic to the Internet Gateway
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.main.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Explicitly associate the main route table with each subnet.
# This is clearer than relying on implicit association and is a best practice.
resource "aws_route_table_association" "main" {
  for_each       = aws_subnet.main
  subnet_id      = each.value.id
  route_table_id = aws_route_table.main.id
}

# --- Post-Creation Validation ---
# The following data sources and resources are used to verify that the primary resources
# were created successfully and are in the expected state.

# Validate that the VPC is available.
data "aws_vpc" "post_check" {
  id = aws_vpc.main.id
  # This ensures the check runs after the resource is created.
  depends_on = [aws_vpc.main]
}

# Validate that the Internet Gateway is attached to the VPC.
data "aws_internet_gateway" "post_check" {
  internet_gateway_id = aws_internet_gateway.main.id
  filter {
    name   = "attachment.vpc-id"
    values = [aws_vpc.main.id]
  }
  depends_on = [aws_internet_gateway.main]
}

# Re-read the route table's state after the internet route has been added.
# This ensures the postcondition check has the most up-to-date information.
data "aws_route_table" "post_check" {
  route_table_id = aws_route_table.main.id
  depends_on     = [aws_route.internet_access]
}

# Validate that the route to the Internet Gateway exists in the main route table.
resource "null_resource" "route_validation" {
  depends_on = [aws_route.internet_access]

  lifecycle {
    postcondition {
      condition     = contains([for r in data.aws_route_table.post_check.routes : r.cidr_block], "0.0.0.0/0")
      error_message = "Post-creation check failed: The 0.0.0.0/0 route was not found in the main route table."
    }
  }
}