output "argocd-id" {
  value = helm_release.argocd.id
}

output "argocd-image-upater-id" {
  value = helm_release.argocd-image-updater.id
}