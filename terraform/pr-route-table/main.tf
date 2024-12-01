resource "aws_route_table" "nat_gw_table" {
  vpc_id = var.vpc-id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id  = var.nat-gateway
  }

  tags = {
    Name = "igw-${var.vpc-id}"
  }
}

resource "aws_route_table_association" "igw_table_ass" {
  for_each = var.private_subnet_ids
  subnet_id = each.value
  route_table_id = aws_route_table.nat_gw_table.id
}