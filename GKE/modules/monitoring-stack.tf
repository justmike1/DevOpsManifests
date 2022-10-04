data "google_secret_manager_secret_version" "client_id" {
  secret = "grafana-oauth2-sso-client-id"
  version = "1"
}
data "google_secret_manager_secret_version" "client_secret" {
  secret = "grafana-oauth2-sso-client-secret"
  version = "1"
}

resource "kubernetes_namespace" "monitoring-ns" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "monitoring-stack" {
  count            = var.enable_monitoring
  chart            = "kube-prometheus-stack"
  cleanup_on_fail  = true
  create_namespace = true
  name             = "kube-prometheus-stack"
  namespace        = kubernetes_namespace.monitoring-ns.metadata.0.name
  repository       = "https://prometheus-community.github.io/helm-charts"
  version          = "40.3.1"
  values = [<<EOF
  grafana:
    grafana.ini:
      auth.google:
        allow_sign_up: true
        allowed_domains: <ORG_EMAIL_DOMAINS>
        auth_url: https://accounts.google.com/o/oauth2/auth
        client_id: ${data.google_secret_manager_secret_version.client_id.secret_data}
        client_secret: ${data.google_secret_manager_secret_version.client_secret.secret_data}
        enabled: true
        scopes: https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email
        token_url: https://accounts.google.com/o/oauth2/token
      server:
        domain: ${local.full_dns}
        #root_url: %(protocol)s://%(domain)s:%(http_port)s/grafana/
        root_url: https://${local.full_dns}/grafana/
        serve_from_sub_path: true
    ingress:  
      enabled: true
      annotations:
        cert-manager.io/cluster-issuer: ${local.cluster_issuer_name}
        cert-manager.io/duration: "2160h"
        cert-manager.io/renew-before: "360h"
        external-dns.alpha.kubernetes.io/hostname: ${local.full_dns}
        kubernetes.io/ingress.allow-http: "false"
        traefik.ingress.kubernetes.io/router.tls: "true"
        kubernetes.io/ingress.class: traefik
      tls:
        - secretName: grafana-tls
          hosts:
            - ${local.full_dns}
    EOF
  ]

  set {
    name  = "kubeStateMetrics.enabled"
    value = false
  }
  set {
    name  = "nodeExporter.enabled"
    value = false
  }
  set {
    name  = "grafana.enabled"
    value = true
  }

  depends_on = [
    module.gke
  ]
}
