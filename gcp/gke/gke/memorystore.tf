module "memorystore" {
  source = "terraform-google-modules/memorystore/google"

  name           = "${var.cluster_name}-memorystore"
  project        = var.project_id
  memory_size_gb = 1
  region         = var.region
  enable_apis    = true
  tier           = "BASIC" # STANDARD_HA for high availability memorystore
}
