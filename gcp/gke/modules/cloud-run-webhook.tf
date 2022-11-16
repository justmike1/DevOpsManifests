# https://github.com/GoogleCloudPlatform/berglas/tree/main/examples/kubernetes
locals {
  berglas_webhook_cloudrun_url = google_cloud_run_service.berglas-webhook-cloudrun.status[0].url
}

resource "null_resource" "create_container_for_cloudrun" {
  count = var.berglas_secret_keys != [] ? 1 : 0
  provisioner "local-exec" {
    command = <<EOT
docker pull ${var.berglas_image}
docker tag ${var.berglas_image} gcr.io/${var.project_id}/berglas_webhook:latest
docker push gcr.io/${var.project_id}/berglas_webhook:latest
  EOT
  }
}

resource "google_cloud_run_service" "berglas-webhook-cloudrun" {
  name     = "${var.cluster_name}-berglas-webhook"
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/berglas_webhook:latest"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    null_resource.create_container_for_cloudrun
  ]
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.berglas-webhook-cloudrun.location
  project  = google_cloud_run_service.berglas-webhook-cloudrun.project
  service  = google_cloud_run_service.berglas-webhook-cloudrun.name

  policy_data = data.google_iam_policy.noauth.policy_data

  depends_on = [
    google_cloud_run_service.berglas-webhook-cloudrun
  ]
}

resource "google_service_account" "berglas_accessor_sa" {
  project      = var.project_id
  account_id   = "berglas-accessor"
  display_name = "Berglas secret accessor account"

  depends_on = [
    kubectl_manifest.berglas-webhook
  ]
}

resource "null_resource" "berglas_grant_secrets" {
  for_each = toset(var.berglas_secret_keys)
  provisioner "local-exec" {
    command = "berglas grant sm://${var.project_id}/${each.key} --member serviceAccount:${google_service_account.berglas_accessor_sa.email}"
  }

  depends_on = [
    google_service_account.berglas_accessor_sa
  ]
}

resource "kubectl_manifest" "berglas-serviceaccount" {
  count     = var.berglas_secret_keys != [] ? 1 : 0
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: berglas-serviceaccount
  namespace: ${var.environment}
  annotations:
    iam.gke.io/gcp-service-account: berglas-accessor@${var.project_id}.iam.gserviceaccount.com
YAML

  depends_on = [
    kubectl_manifest.berglas-webhook,
    kubernetes_namespace.environment_ns
  ]
}

resource "google_service_account_iam_binding" "berglas-serviceaccount-binding" {
  service_account_id = google_service_account.berglas_accessor_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.environment}/berglas-serviceaccount]",
  ]

  depends_on = [
    google_service_account.berglas_accessor_sa
  ]
}

resource "kubectl_manifest" "berglas-webhook" {
  count     = var.berglas_secret_keys != [] ? 1 : 0
  yaml_body = <<YAML
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: berglas-webhook
  labels:
    app: berglas-webhook
    kind: mutator

webhooks:
- name: berglas-webhook.cloud.google.com
  admissionReviewVersions: ["v1", "v1beta1"]
  sideEffects: NoneOnDryRun
  clientConfig:
    url: ${local.berglas_webhook_cloudrun_url}
    caBundle: ""
  rules:
  - operations: ["CREATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
YAML

  depends_on = [
    google_cloud_run_service.berglas-webhook-cloudrun,
  ]
}
