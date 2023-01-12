resource "helm_release" "external-dns" {
  name             = "external-dns"
  chart            = "external-dns"
  version          = "1.12.0"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  namespace        = kubernetes_namespace.ingress-ns.metadata.0.name
  create_namespace = false
  values = [<<EOF
serviceAccount:
  annotations:
    iam.gke.io/gcp-service-account: ${google_service_account.external-dns-sa.email} 
nodeSelector:
  iam.gke.io/gke-metadata-server-enabled: "true"
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
    name  = "provider"
    value = "google"
  }
  set {
    name  = "extraArgs"
    value = "{--google-project=${var.dns_project},--google-zone-visibility=public}"
  }
  set {
    name  = "logFormat"
    value = "json"
  }
  set {
    name  = "policy"
    value = "sync"
  }
  set {
    name  = "txtOwnerId"
    value = var.cluster_name
  }
  set {
    name  = "domainFilters[0]"
    value = var.domain
  }

  depends_on = [
    module.gke,
    google_service_account_iam_binding.dns-admin-account-iam
  ]
}
