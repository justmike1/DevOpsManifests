# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
# cluster's service account
resource "google_service_account" "kubernetes" {
  account_id   = "kubernetes"
  project      = var.project_id
  display_name = "${var.cluster_name}'s node pools service account"
}
