variable "public_subnets_map" {
  type = map(string)
  
}

variable "private_subnets_map" {
  type = map(string)
}

variable "vpc-name" {
  type = string
}