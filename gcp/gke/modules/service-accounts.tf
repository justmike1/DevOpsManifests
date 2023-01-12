# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
# cluster's service account
resource "google_service_account" "cluster-sa" {
  account_id   = var.cluster_name
  project      = var.project_id
  display_name = "${var.cluster_name}'s node pools service account"
}

# scheduler's service account
resource "google_service_account" "scheduler-sa" {
  account_id   = "${var.cluster_name}-cloud-scheduler"
  project      = var.project_id
  display_name = "${var.cluster_name}'s scheduler service account to generate tokens"
  depends_on = [
    module.gke
  ]
}

# Allow SA service account use the default GCE account
resource "google_service_account_iam_member" "gce-default-account-iam" {
  for_each = toset(["roles/run.serviceAgent", "roles/cloudscheduler.serviceAgent", "roles/editor"])

  service_account_id = google_service_account.scheduler-sa.name
  role               = each.key
  member             = "serviceAccount:${google_service_account.scheduler-sa.email}"
  depends_on = [
    google_service_account.scheduler-sa
  ]
}

resource "google_service_account_key" "artifactory_sa_key" {
  count              = var.artifactory_sa_email != null ? 1 : 0
  service_account_id = var.artifactory_sa_email
}

locals {
  registry_username = "_json_key"
  registry_password = base64decode(google_service_account_key.artifactory_sa_key[0].private_key)
}

resource "kubernetes_secret" "gcr-json-key" {
  for_each = toset(["default", var.environment])
  metadata {
    name      = "gcr-json-key"
    namespace = each.key
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "https://gcr.io" = {
          "username" = local.registry_username
          "password" = local.registry_password
          "auth"     = base64encode("${local.registry_username}:${local.registry_password}")
        }
      }
    })
  }

  depends_on = [
    google_service_account_key.artifactory_sa_key,
    kubernetes_namespace.environment_ns
  ]
}


resource "google_service_account" "external-dns-sa" {
  account_id   = "external-dns-sa"
  project      = var.project_id
  display_name = "A service account that was made for external-dns service"

  depends_on = [
    helm_release.ingress-controller
  ]
}

resource "google_project_iam_binding" "dns_project_admin" {
  project = var.dns_project
  role    = "roles/dns.admin"

  members = [
    "serviceAccount:${google_service_account.external-dns-sa.email}",
  ]

  depends_on = [
    google_service_account.external-dns-sa
  ]
}

resource "google_service_account_iam_binding" "dns-admin-account-iam" {
  service_account_id = google_service_account.external-dns-sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_namespace.ingress-ns.metadata.0.name}/external-dns]",
  ]

  depends_on = [
    google_project_iam_binding.dns_project_admin
  ]
}

