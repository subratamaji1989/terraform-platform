output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = { for k, v in aws_subnet.main : k => v.id }
}

output "route_table_id" {
  value = aws_route_table.main.id
}