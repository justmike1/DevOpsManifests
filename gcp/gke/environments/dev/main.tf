module "gke-cluster" {
  source            = "../../modules/"
  cluster_name      = "dev-gke"
  project_id        = "mikejoseph-devops"
  domain            = "super.devops.com"
  region            = "us-central1"
  backend_bucket    = "mikejoseph-tf-state-dev"
  enable_runner     = 0
  enable_monitoring = 1
  machine_type      = "e2-medium"
  environment       = "dev"
}
