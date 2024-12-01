resource "aws_subnet" "pr-subnet" {
  for_each = var.private_subnets_map
  vpc_id = var.vpc-name
  cidr_block = each.value
  availability_zone = each.key
  tags = {
    Name = "pr-subnet-${var.vpc-name}"
  }
}

resource "aws_subnet" "pb-subnet" {
    for_each = var.public_subnets_map
    vpc_id = var.vpc-name
    cidr_block = each.value
    availability_zone = each.key
    map_public_ip_on_launch = true
  tags = {
    Name = "pb-subnet-${var.vpc-name}"
  }
}
