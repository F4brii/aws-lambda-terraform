output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_id" {
  value = aws_subnet.subnet.id
}

output "default_route_table_id" {
  value = aws_vpc.vpc.default_route_table_id
}

output "vpc_cidr_block" {
  value = aws_vpc.vpc.cidr_block
}
