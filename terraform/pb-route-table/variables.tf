variable "vpc-id" {
  type = string
}
variable "igw" {
  type = string
}
variable "public_subnet_ids" {
  type = map(string)
}