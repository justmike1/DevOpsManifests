resource "helm_release" "external-dns" {
  name             = "external-dns"
  chart            = "external-dns"
  version          = "1.11.0"
  repository       = "https://kubernetes-sigs.github.io/external-dns"
  namespace        = kubernetes_namespace.ingress-ns.metadata.0.name
  create_namespace = true
  values = [<<EOF
nodeSelector:
  iam.gke.io/gke-metadata-server-enabled: "true"
env:
  - name: GOOGLE_APPLICATION_CREDENTIALS
    value: /etc/secrets/service-account/credentials.json
extraVolumes:
  - name: google-service-account
    secret:
      secretName: external-dns-sa
extraVolumeMounts:
  - name: google-service-account
    mountPath: /etc/secrets/service-account/
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
  set {
    name  = "serviceAccount.name"
    value = split("@", var.clouddns_sa_email)[0]
  }

  depends_on = [
    module.gke,
    helm_release.ingress-controller,
    kubernetes_secret.external-dns-sa
  ]
}
