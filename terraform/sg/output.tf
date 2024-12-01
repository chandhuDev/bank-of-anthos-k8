output "sg-id" {
  value = aws_security_group.jenkins-sg.id
}

output "eks-sfn-sg" {
  value = aws_security_group.eks-sfn-sg.id
}