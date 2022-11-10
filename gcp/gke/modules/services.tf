# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service
resource "google_project_service" "compute" {
  service                    = "compute.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "container" {
  service                    = "container.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "certificate-authority-service" {
  service                    = "privateca.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "networking-service" {
  service                    = "servicenetworking.googleapis.com"
  disable_dependent_services = true
}
