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

resource "google_project_service" "scheduler-service" {
  service                    = "cloudscheduler.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "pubsub-service" {
  service                    = "pubsub.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "artifactregistry-service" {
  service                    = "artifactregistry.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "cloudbuild-service" {
  service                    = "cloudbuild.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "cloudrun-service" {
  service                    = "run.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "cloudkms-service" {
  service                    = "cloudkms.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "storage-api-service" {
  service                    = "storage-api.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "storage-component-service" {
  service                    = "storage-component.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "secretmanager-service" {
  service                    = "secretmanager.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "cloudfunctions-service" {
  service                    = "cloudfunctions.googleapis.com"
  disable_dependent_services = true
}
