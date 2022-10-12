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
    global:
      podSecurityPolicy:
        enabled: true
        useAppArmor: true
    prometheus:
      enabled: false
    installCRDs: true
  EOF
  ]
  depends_on = [
    helm_release.ingress-controller,
    module.gke
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
    email: <SOME_EMAIL_FOR_NOTIFICATIONS>
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: ${local.cluster_issuer_name}-account-key
    solvers:
    - dns01:
        cloudDNS:
          project: <PROJECT WITH THE DNS>
          serviceAccountSecretRef:
            name: external-dns-sa
            key: credentials.json
YAML

  depends_on = [
    helm_release.cm
  ]
}
