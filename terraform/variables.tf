variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "dns_support" {
  default = true
}

variable "dns_hostnames" {
  default = true
}

variable "instance_tenancy" {
  default = "default"
}

variable "public_subnets_map" {
  type = map(string)

}

variable "private_subnets_map" {
  type = map(string)
}

variable "ami-id" {
  type = string
}

variable "intance_type" {
  type = string
}

variable "public_azs" {
  type = string
}

variable "eks-node-name" {
  type = string
}

variable "region" {
  type = string
}

variable "ec2-subnet" {
  type = string
}

variable "instance_image" {
  type = string
}

variable "eks-sf-node-name" {
  type = string
}