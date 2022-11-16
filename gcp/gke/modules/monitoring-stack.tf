data "google_secret_manager_secret_version" "client_id" {
  secret  = "grafana-oauth2-sso-client-id"
  project = var.dns_project
  version = "1"
}
data "google_secret_manager_secret_version" "client_secret" {
  secret  = "grafana-oauth2-sso-client-secret"
  project = var.dns_project
  version = "1"
}
data "google_secret_manager_secret_version" "admin_password" {
  secret  = "grafana-admin-password"
  project = var.dns_project
  version = "1"
}
data "google_secret_manager_secret_version" "gcm_sa" {
  secret  = "google-cloud-monitoring-sa-grafana"
  project = var.dns_project
  version = "1"
}
data "google_secret_manager_secret_version" "slack_webhook" {
  secret  = "slack-app-alerts-webhook-url"
  project = var.dns_project
  version = "1"
}

resource "helm_release" "monitoring-stack" {
  count            = var.enable_monitoring
  chart            = "kube-prometheus-stack"
  cleanup_on_fail  = true
  create_namespace = true
  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  version          = "41.7.3"
  values = [<<EOF
grafana:
  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources:
      - name: Google Cloud Monitoring
        type: stackdriver
        access: proxy
        jsonData:
          tokenUri: https://oauth2.googleapis.com/token
          clientEmail: monitoring-instances-grafana@med-and-beyond.iam.gserviceaccount.com
          authenticationType: jwt
          defaultProject: med-and-beyond
        secureJsonData:
          privateKey: "${data.google_secret_manager_secret_version.gcm_sa.secret_data}"
  dashboardProviders:
    dashboardproviders.yaml:
     apiVersion: 1
     providers:
      - name: 'infrastructure'
        orgId: 1
        folder: 'infrastructure'
        type: file
        disableDeletion: false
        updateIntervalSeconds: 10 
        allowUiUpdates: true
        editable: true
        options:
          path: /var/lib/grafana/dashboards/infrastructure
  dashboards:
    infrastructure:
      production-metrics:
        json: |
          ${indent(10, file("${path.module}/grafana-dashboards/production-metrics.json"))}
      development-metrics:
        json: |
          ${indent(10, file("${path.module}/grafana-dashboards/development-metrics.json"))}
      staging-metrics:
        json: |
          ${indent(10, file("${path.module}/grafana-dashboards/staging-metrics.json"))}
  alerting:
    contactpoints.yaml:
      apiVersion: 1
      contactPoints:
        - name: slack-alert_channel_dev-alerts
          receivers:
            - uid: notifier1
              type: slack
              settings:
                recipient: dev-alerts
                mentionUsers: ${var.slack_alert_users_ids}
                url: "${data.google_secret_manager_secret_version.slack_webhook.secret_data}"
                endpointUrl: https://custom_url/api/chat.postMessage
  grafana.ini:
    auth.google:
      allow_sign_up: true
      allowed_domains: ${var.domain} ${endswith(var.domain, ".ai") ? replace(var.domain, ".ai", ".com") : ""}
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
    hosts: ["${local.full_dns}"]
    annotations:
      apiVersion: networking.k8s.io/v1
      kubernetes.io/ingress.allow-http: "false"
      kubernetes.io/ingress.class: "traefik"
      external-dns.alpha.kubernetes.io/hostname: "${local.full_dns}"
    path: /grafana
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
  set {
    name  = "grafana.defaultDashboardsEnabled"
    value = false
  }
  set {
    name  = "grafana.adminPassword"
    value = data.google_secret_manager_secret_version.admin_password.secret_data
  }
  set {
    name  = "grafana.persistence.enabled"
    value = true
  }
  set {
    name  = "grafana.persistence.size"
    value = "1Gi"
  }

  depends_on = [
    module.gke,
    helm_release.ingress-controller,
    helm_release.external-dns
  ]
}
