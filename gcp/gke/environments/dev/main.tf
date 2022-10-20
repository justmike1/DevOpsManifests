module "gke-cluster" {
  source         = "../../modules/"
  cluster_name   = "dev-gke"
  project_id     = "mikejoseph-devops"
  region         = "us-central1"
  backend_bucket = "mikejoseph-tf-state-dev"

  # dns settings  
  dns_project = "mike-dns" # also for general secrets
  domain      = "devops.com"
  sub_domain  = "super"

  # miscellaneous
  devops_email      = "top_devops@gmail.com"
  enable_runner     = 0
  enable_monitoring = 1
  machine_type      = "e2-medium"
  environment       = "dev"

  # sql instance settings
  sql_region    = "us-central1"
  sql_disk_size = 100
  sql_tier      = "db-custom-4-26624"
  sql_databases = ["I", "can", "do", "it", "all"]

  # cluster_cidr = "10.48.0.0/14"
}
