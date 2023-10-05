resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = var.vpc_name
  }
}



resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = format("%s-IGW", var.vpc_name)
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_gw.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = format("%s-NAT", var.vpc_name)
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "nat_gw" {
}