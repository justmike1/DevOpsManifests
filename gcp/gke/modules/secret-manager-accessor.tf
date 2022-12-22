# microservices's service account
resource "google_service_account" "microservices_iam_sa" {
  count = var.google_secret_manager_keys != [] && var.old_service_accounts != [] ? 1 : 0

  account_id   = "${var.cluster_name}-micro-services-sa"
  project      = var.project_id
  display_name = "${var.cluster_name}'s service account to read only secrets"
  depends_on = [
    module.gke
  ]
}

resource "google_secret_manager_secret_iam_binding" "secret_manager_readonly_role" {
  for_each = toset(var.google_secret_manager_keys)

  project   = var.project_id
  secret_id = each.key
  role      = "roles/secretmanager.secretAccessor"

  members = [
    "serviceAccount:${google_service_account.microservices_iam_sa[0].email}",
  ]

  depends_on = [
    google_service_account.microservices_iam_sa
  ]
}

resource "google_service_account_iam_binding" "secret_manager_workload_indentity" {
  count              = var.google_secret_manager_keys != [] ? 1 : 0
  service_account_id = google_service_account.microservices_iam_sa[count.index].name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.environment}/micro-services-sa]",
  ]

  depends_on = [
    google_secret_manager_secret_iam_binding.secret_manager_readonly_role,
    google_service_account.microservices_iam_sa,
    kubernetes_namespace.environment_ns
  ]
}

resource "kubectl_manifest" "secret_manager_k8s_serviceaccount" {
  count     = var.google_secret_manager_keys != [] ? 1 : 0
  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: micro-services-sa
  namespace: ${var.environment}
  annotations:
    iam.gke.io/gcp-service-account: ${google_service_account.microservices_iam_sa[count.index].email}
YAML

  depends_on = [
    google_secret_manager_secret_iam_binding.secret_manager_readonly_role,
    google_service_account.microservices_iam_sa,
    kubernetes_namespace.environment_ns,
    google_service_account_iam_binding.bind_old_service_accounts
  ]
}

resource "google_service_account_iam_binding" "bind_old_service_accounts" {
  count = var.old_service_accounts != [] ? 1 : 0

  service_account_id = google_service_account.microservices_iam_sa[count.index].name
  role               = "roles/editor"
  members            = var.old_service_accounts

  depends_on = [
    google_service_account.microservices_iam_sa,
  ]
}
