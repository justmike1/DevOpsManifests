resource "kubernetes_namespace" "runner-ns" {
  metadata {
    name = "self-hosted-runners"
  }
}

resource "helm_release" "runner" {
  count = var.enable_addons
  name  = "runner"
  chart = "./charts/runner"

  namespace        = kubernetes_namespace.runner-ns.metadata[0].name
  create_namespace = true

  values = [<<EOF
  namespace: ${kubernetes_namespace.runner-ns.metadata[0].name}
  EOF
  ]
}
