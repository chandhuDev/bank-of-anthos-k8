resource "aws_route_table" "igw_table" {
  vpc_id = var.vpc-id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw
  }

  tags = {
    Name = "igw-${var.vpc-id}"
  }
}

resource "aws_route_table_association" "igw_table_ass" {
  subnet_id = var.public_subnet_ids["us-east-2b"]
  
  route_table_id = aws_route_table.igw_table.id
}