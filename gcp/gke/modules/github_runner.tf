data "google_secret_manager_secret_version" "github_token" {
  secret  = "github-runner-controller-token"
  project = var.dns_project
  version = "1"
}

resource "kubernetes_namespace" "arc" {
  count = var.enable_github_runner
  metadata {
    name = "actions-runner-system"
  }
}

resource "helm_release" "actions-runner-controller" {
  count            = var.enable_github_runner
  name             = "actions-runner-controller"
  namespace        = kubernetes_namespace.arc[count.index].metadata[0].name
  create_namespace = true
  chart            = "actions-runner-controller"
  repository       = "https://actions-runner-controller.github.io/actions-runner-controller"
  version          = "v0.21.1"
  values = [<<EOF
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: role
          operator: In
          values:
          - master
  EOF
  ]

  set {
    name  = "authSecret.create"
    value = true
  }
  set {
    name  = "authSecret.github_token"
    value = data.google_secret_manager_secret_version.github_token.secret_data
  }

  depends_on = [
    resource.helm_release.cm
  ]
}
