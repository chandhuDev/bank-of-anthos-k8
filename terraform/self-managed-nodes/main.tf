resource "aws_iam_role" "self_managed_nodes" {
  name = "eks-self-managed-nodes"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.self_managed_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry" {
  role       = aws_iam_role.self_managed_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.self_managed_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


resource "aws_iam_role_policy_attachment" "eks-instance-core" {
  role       = aws_iam_role.self_managed_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "eks_sf_node" {
  name = "eks_self_node_instance_profile"
  path = "/"
  role = aws_iam_role.self_managed_nodes.id
}

# resource "kubernetes_config_map" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = {
#     mapRoles = <<-EOT
#       - rolearn: arn:aws:iam::${aws_iam_role.self_managed_nodes.arn}
#         username: system:node:{{EC2PrivateDNSName}}
#         groups:
#           - system:bootstrappers
#           - system:nodes
#     EOT

#     mapAccounts = <<-EOT
#       - "123456789012"
#     EOT
#   }
# }

resource "aws_launch_configuration" "EC2_instance" {
  name_prefix          = "eks-node-launch"
  instance_type        = var.smn-instance-type
  image_id             = var.smn-node-image
  iam_instance_profile = aws_iam_instance_profile.eks_sf_node.name
  security_groups      = [var.eks-smn-security-group]

  user_data = base64encode(<<EOF
    #!/bin/bash
    set -o xtrace
    /etc/eks/bootstrap.sh ${var.eks_cluster_name}
    /opt/aws/bin/cfn-signal --exit-code $? \
                --stack  ${var.eks_cluster_name}-stack \
                --resource NodeGroup  \
                --region us-east-2
    EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks_autoscaling_group" {
  name                 = "eks-self-managed"
  launch_configuration = aws_launch_configuration.EC2_instance.name
  min_size             = 2
  max_size             = 4
  desired_capacity     = 3
  vpc_zone_identifier  = [var.subnet_ids["us-east-2a"], var.subnet_ids["us-east-2b"]]

  instance_maintenance_policy {
    min_healthy_percentage = 70
    max_healthy_percentage = 120
  }

  tag {
    key                 = "Name"
    value               = "${var.nodeName}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.eks_cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [var.eks_cluster_name]
}


resource "aws_eks_access_entry" "example" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.self_managed_nodes.arn

  type = "STANDARD"
}
