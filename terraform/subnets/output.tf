output "subnet_ids_pb" {
  value = { for subnet in aws_subnet.pb-subnet: subnet.availability_zone => subnet.id }
}

output "subnet_ids_pr" {
  value = { for subnet in aws_subnet.pr-subnet: subnet.availability_zone => subnet.id }
}