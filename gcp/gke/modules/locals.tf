locals {
  full_dns = "${replace(var.sub_domain, "-", ".")}.${var.domain}"
}

locals {
  cluster_issuer_name = "${var.cluster_name}-issuer"
}

locals {
  system_ns = "kube-system"
}

locals {
  prod_acme    = "https://acme-v02.api.letsencrypt.org/directory"
  staging_acme = "https://acme-staging-v02.api.letsencrypt.org/directory"
}
