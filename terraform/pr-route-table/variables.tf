variable "vpc-id" {
  type = string
}
variable "nat-gateway" {
  type = string
}
variable "private_subnet_ids" {
  type = map(string)
}