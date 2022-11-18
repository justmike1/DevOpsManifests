module "gke-cluster" {

  source                      = "../../modules/"
  cluster_name                = "dev-gke"
  project_id                  = "mikejoseph-devops"
  region                      = "us-central1"
  backend_bucket              = "mikejoseph-tf-state-dev"
  services_machine_type       = "e2-standard-8"
  infrastructure_machine_type = "c2d-highcpu-4"
  environment                 = "dev"

  # service accounts secrets settings
  artifactory_sa_email = "artifacts-sa-rw@art-project.iam.gserviceaccount.com"
  clouddns_sa_email    = "project-num-compute@developer.gserviceaccount.com"

  # google secret manager settings (must be already present in secret manager)
  # if you want to use berglas set:
  berglas_secret_keys = ["POSTGRES_USER", "POSTGRES_PASSWORD"]
  # if you want to use secret manager with 'tavisod' python package set:
  google_secret_manager_keys = ["POSTGRES_USER", "POSTGRES_PASSWORD"]

  # pubsub & scheduler settings
  pubsub_topics = ["somepubsub", "somepubsub2"]
  scheduler_jobs = {
    "some-scheduler" : ["* * * * *", "Africa/Abidjan"],
    "some-scheduler2" : ["* 2 * * *", "US/Central"]
  }

  # dns settings  
  enable_cert-manager = 0
  dns_project         = "mike-dns" # also for general secrets
  domain              = "devops.com"
  sub_domain          = "super"

  # monitoring settings
  enable_monitoring     = 0
  enable_jenkins        = 0
  slack_alert_users_ids = "U04763JSG3Z,U0JDG73H3,U03236RTGD"
  devops_email          = "super_devops@mikejoseph.com"

  # sql instance settings
  sql_region         = "us-central1"
  sql_disk_size      = 100
  sql_tier           = "db-custom-4-26624"
  sql_high_available = false
  sql_databases      = ["db1", "db2", "db3"]

  # cluster_cidr = "10.48.0.0/14"
}