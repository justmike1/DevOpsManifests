resource "kubernetes_namespace" "prometheus-ns" {
  metadata {
    name = "self-hosted-runners"
  }
}

resource "helm_release" "runner" {
  count = var.enable_prometheus
  name  = "runner"
  chart = "./charts/runner"

  namespace        = kubernetes_namespace.prometheus-ns.metadata[0].name
  create_namespace = true

  values = [<<EOF
  namespace: ${kubernetes_namespace.prometheus-ns.metadata[0].name}
  EOF
  ]
}
