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