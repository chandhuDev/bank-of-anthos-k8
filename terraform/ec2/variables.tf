variable "vpc-id" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "ami" {
  type = string
}
variable "az" {
  type = string
}
variable "public_subnet_ids" {
  type = map(string)
}
variable "aws_key_pair_name" {
  type = string
}
variable "sg" {
  type = string
}