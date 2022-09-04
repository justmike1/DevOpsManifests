data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "github/access_token"
}
locals {
  github_creds = jsondecode(
    data.aws_secretsmanager_secret_version.creds.secret_string
  )
}

resource "kubernetes_namespace" "arc" {
  metadata {
    name = "actions-runner-system"
  }
}

resource "helm_release" "actions-runner-controller" {
  count            = var.actions_runner_controller
  name             = "actions-runner-controller"
  namespace        = kubernetes_namespace.arc.metadata[0].name
  create_namespace = true
  chart            = "actions-runner-controller"
  repository       = "https://actions-runner-controller.github.io/actions-runner-controller"
  version          = "v0.20.2"
  values = [<<EOF
    authSecret:
      github_token: ${local.github_creds.github_token}
      create: true
  EOF
  ]
  depends_on = [resource.helm_release.cm]
}

