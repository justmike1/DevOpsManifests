locals {
  prod_acme           = "https://acme-v02.api.letsencrypt.org/directory"
  staging_acme        = "https://acme-staging-v02.api.letsencrypt.org/directory"
  cluster_issuer_name = "${var.cluster_name}-issuer"
}

resource "helm_release" "cm" {
  count            = var.enable_github_runner == 1 || var.enable_cert_manager == 1 ? 1 : 0
  name             = "cert-manager"
  namespace        = kubernetes_namespace.ingress-ns.metadata.0.name
  create_namespace = true
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  version          = "v1.10.0"
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
    name  = "global.podSecurityPolicy.enabled"
    value = true
  }
  set {
    name  = "global.podSecurityPolicy.useAppArmor"
    value = true
  }
  set {
    name  = "prometheus.enabled"
    value = false
  }
  set {
    name  = "installCRDs"
    value = true
  }
  set {
    name  = "startupapicheck.timeout"
    value = "5m"
  }

  depends_on = [
    module.gke,
  ]
}

# server: ${var.environment != "prod" || var.environment != "production" ? local.staging_acme : local.prod_acme}
resource "kubectl_manifest" "cas-cluster-issuer-staging" {
  count     = var.enable_cert_manager
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${local.cluster_issuer_name}-staging
  namespace: "${kubernetes_namespace.ingress-ns.metadata.0.name}"
spec:
  acme:
    email: ${var.devops_email}
    server: ${local.staging_acme}
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: ${local.cluster_issuer_name}-account-key
    solvers:
    - dns01:
        cloudDNS:
          project: ${var.dns_project}
          serviceAccountSecretRef:
            name: external-dns-sa
            key: credentials.json
YAML

  depends_on = [
    helm_release.cm,
  ]
}
resource "kubectl_manifest" "cas-cluster-issuer-prod" {
  count     = var.enable_cert_manager
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${local.cluster_issuer_name}-prod
  namespace: "${kubernetes_namespace.ingress-ns.metadata.0.name}"
spec:
  acme:
    email: ${var.devops_email}
    server: ${local.prod_acme}
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: ${local.cluster_issuer_name}-account-key
    solvers:
    - dns01:
        cloudDNS:
          project: ${var.dns_project}
          serviceAccountSecretRef:
            name: external-dns-sa
            key: credentials.json
YAML

  depends_on = [
    helm_release.cm,
  ]
}