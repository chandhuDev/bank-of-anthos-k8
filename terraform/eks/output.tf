output "endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "eks-name" {
  value = aws_eks_cluster.eks.name
}

output "eks-version" {
  value = aws_eks_cluster.eks.version
}

output "eks-id" {
  value = aws_eks_cluster.eks.id
}

output "kubeconfig-data" {
  value = aws_eks_cluster.eks.certificate_authority
}