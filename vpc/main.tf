
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "subnet" {
  cidr_block              = var.subnet_cidr
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
}
