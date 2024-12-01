variable "eks-name" {
  type = string
}
variable "region" {
  type = string
}
variable "nodeName" {
  type = string
}
variable "subnet_ids" {
  type = map(string)
}
variable "eks-version" {
  type = string
}