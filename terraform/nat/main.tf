resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = "eip-${var.vpc-id}"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = var.public_subnet_ids["us-east-2b"]

  tags = {
    Name = "nat-gw-${var.vpc-id}"
  }

  
  depends_on = [var.igw-id]
}


