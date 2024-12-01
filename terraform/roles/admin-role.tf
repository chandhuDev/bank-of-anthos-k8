data "aws_caller_identity" "current" {}

resource "aws_iam_role" "admin-role" {
  name               = "admin-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "admin-role-policy" {
  name   = "admin-role-policy"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "eks.amazonaws.com"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "admin-role-attachment" {
  policy_arn = aws_iam_policy.admin-role-policy.arn
  role = aws_iam_role.admin-role.name
}


resource "aws_iam_user" "admin-user" {
  name = "admin-cluster-user"
}

resource "aws_iam_policy" "admin-user-policy" {
  name = "AmazonEKSAdminPolicy"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Resource": "${aws_iam_role.admin-role.arn}"
        }
    ]
}
POLICY
}

resource "aws_iam_user_policy_attachment" "admin-role-attachment" {
  user = aws_iam_user.admin-user.name
  policy_arn = aws_iam_policy.admin-role-policy.arn
}

resource "aws_eks_access_entry" "admin-acess-entry" {
  cluster_name      = var.eks-name
  principal_arn     = aws_iam_role.admin-role.arn
  kubernetes_groups = ["cluster-admin-role"]
}
