resource "kubernetes_namespace" "environment_ns" {
  metadata {
    name = var.environment
  }

  depends_on = [
    module.gke
  ]
}

locals {
  full_dns = "${replace(var.sub_domain, "-", ".")}.${var.domain}"
}
