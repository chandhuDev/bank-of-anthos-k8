variable "vpc-id" {
  type = string
}

variable "private_subnet_ids" {
  type = map(string)
}