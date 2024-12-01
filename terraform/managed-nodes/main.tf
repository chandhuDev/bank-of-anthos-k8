resource "aws_iam_role" "example" {
  name = "eks-managed-node-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.example.name
}

resource "aws_eks_node_group" "example" {
  cluster_name    = var.eks-name
  node_group_name = "${var.eks-name}-${var.nodeName}"
  node_role_arn   = aws_iam_role.example.arn
  subnet_ids      = [var.subnet_ids["us-east-2a"], var.subnet_ids["us-east-2b"]]
  version         = var.eks-version

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.large"]
  scaling_config {
    desired_size = 5
    max_size     = 5
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    "Name"                             = "${var.eks-name}-mn"
    "kubernetes.io/cluster/${var.eks-name}" = "owned"
  }

  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]


  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
