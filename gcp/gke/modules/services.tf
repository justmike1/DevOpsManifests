# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service

locals {
  services = ["container.googleapis.com", "servicenetworking.googleapis.com", "cloudscheduler.googleapis.com", "pubsub.googleapis.com", "artifactregistry.googleapis.com", "cloudkms.googleapis.com", "storage-api.googleapis.com", "storage-component.googleapis.com", "secretmanager.googleapis.com", "sqladmin.googleapis.com"]
}
resource "google_project_service" "project_services" {
  for_each                   = toset(var.environment != "prod" ? local.services : [])
  service                    = each.key
  disable_dependent_services = true

  # DON'T DESTROY THIS RESOURCE, IF YOU WANT TO THEN ONLY REMOVE IT FROM STATE
  # RUN "terraform state rm module.gke-cluster.google_project_service.project_services"
  lifecycle {
    prevent_destroy = true
  }
}
