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
