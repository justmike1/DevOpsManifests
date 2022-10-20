resource "kubernetes_namespace" "cm-ns" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cm" {
  name             = "cert-manager"
  namespace        = kubernetes_namespace.cm-ns.metadata.0.name
  create_namespace = true
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  version          = "v1.9.1"
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

resource "kubectl_manifest" "cas-cluster-issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${local.cluster_issuer_name}
  namespace: ${kubernetes_namespace.cm-ns.metadata.0.name} 
spec:
  acme:
    email: ${var.devops_email}
    server: ${var.environment != "prod" || var.environment != "production" ? local.staging_acme : local.prod_acme}
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
