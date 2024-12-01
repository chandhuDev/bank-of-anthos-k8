# helm install argocd -n argocd --create-namespace argo/argo-cd --version 3.35.4 -f terraform/values/argocd.yaml
# helm install argocd -n argocd --create-namespace argo/argo-cd --version 0.8.4 -f terraform/values/argocd-image-updater.yaml
provider "helm" {
  kubernetes {
    host                   = var.eks-host
    cluster_ca_certificate = base64decode(var.eks-certificate)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.eks-name]
      command     = "aws"
    }
  }
}

data "aws_instances" "eks" {
  instance_tags = {
    Name = "eks-main-mn"
  }
}

resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.3.11"
  timeout          = 1200
  wait             = false
  values           = [file("values/argocd.yaml")]
  depends_on = [ data.aws_instances.eks ]
}

resource "helm_release" "argocd-image-updater" {
  name = "argocd-image-updater"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-image-updater"
  namespace        = "argocd"
  create_namespace = true
  version          = "0.8.4"
  wait             = false
  timeout          = 1200
  # values           = [file("values/argocd-image-updater.yaml")]
}


# resource "aws_eks_addon" "pod_identity" {
  
# }
