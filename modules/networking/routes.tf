resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  depends_on = [aws_nat_gateway.nat]

  tags = {
    Name = format("%s-private-table", var.vpc_name)
  }
}

resource "aws_route" "private_egress" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
  depends_on             = [aws_route_table.private_route_table]
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = format("%s-public-table", var.vpc_name)
  }
}

resource "aws_route" "public_egress" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_route_table.public_route_table]
}

