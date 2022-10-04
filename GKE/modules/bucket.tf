resource "google_storage_bucket" "backend" {
  name          = var.backend_bucket
  location      = "US"
  storage_class = "STANDARD"

  versioning {
    enabled = true
  }
  labels = {
    "project" = var.project_id
  }
}
