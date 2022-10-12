locals {
  full_dns = "${replace(var.cluster_name, "-", ".")}.${var.domain}"
}

locals {
  cluster_issuer_name = "${var.cluster_name}-issuer"
}
