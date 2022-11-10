module "gke-cluster" {

  source         = "../../modules/"
  cluster_name   = "dev-gke"
  project_id     = "mikejoseph-devops"
  region         = "us-central1"
  backend_bucket = "mikejoseph-tf-state-dev"
  services_machine_type       = "e2-standard-8"
  infrastructure_machine_type = "c2d-highcpu-4"
  environment                 = "dev"

  # dns settings  
  enable_cert-manager = 0
  dns_project = "mike-dns" # also for general secrets
  domain      = "devops.com"
  sub_domain  = "super"

  # monitoring settings
  enable_monitoring     = 0
  enable_jenkins        = 0
  slack_alert_users_ids = "U04763JSG3Z,U0JDG73H3,U03236RTGD"
  devops_email          = "super_devops@mikejoseph.com"

  # sql instance settings
  sql_region    = "us-central1"
  sql_disk_size = 100
  sql_tier      = "db-custom-4-26624"
  sql_databases = ["dm", "emr", "florence", "freud_db", "fub", "htn", "mh", "mtb", "diagnosis"]

  # cluster_cidr = "10.48.0.0/14"
}
