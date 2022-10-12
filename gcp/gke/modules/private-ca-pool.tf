resource "google_privateca_ca_pool" "certs-pool" {
  name = "${var.cluster_name}-certs-pool"
  location = var.region
  tier = "DEVOPS"
  publishing_options {
    publish_ca_cert = true
    publish_crl = false
  }
  labels = {
    environment = var.environment
  }
  depends_on = [
    google_project_service.certificate-authority-service
  ]
}
