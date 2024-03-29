variable "project_id" {
  type        = string
  description = "name of the project in google cloud"
}

variable "domain" {
  type        = string
  description = "domain of the cluster"
}

variable "sub_domain" {
  type        = string
  description = "sub domain of the cluster"
}

variable "devops_email" {
  type        = string
  description = "org's devops team email"
}

variable "backend_bucket" {
  type        = string
  description = "name of the gcs backend bucket"
}

variable "region" {
  type        = string
  description = "cluster's region"
}

variable "cluster_name" {
  type        = string
  description = "cluster's name"
}

variable "dns_project" {
  type        = string
  description = "cloudDNS project"
}

variable "environment" {
  type        = string
  description = "cluster's env"
}

variable "enable_monitoring" {
  type        = number
  description = "deploy monitoring stack (grafana + prom)"
  default     = 0
}

variable "sql_require_ssl" {
  type        = bool
  description = "whether the google sql instance requires ssl for connections"
  default     = false
}

variable "enable_github_runner" {
  type        = number
  description = "if to enable github runner"
  default     = 0
}

variable "enable_jenkins" {
  type        = number
  description = "deploy jenkins stack"
  default     = 0
}

variable "enable_cert_manager" {
  type        = number
  description = "deploy cert-manager with let's encrypt clusterissuers"
  default     = 0
}

variable "slack_alert_users_ids" {
  type        = string
  description = "User Ids for alerts to be tagged & mentions, I.E: U049K3NPYTW,U036RNV3PL3,U02LFDBIP9A"
  default     = ""
}

variable "infrastructure_machine_type" {
  type        = string
  description = "cluster's infrastructure node pool machine"
  default     = "e2-small"
}

variable "services_machine_type" {
  type        = string
  description = "cluster's services node pool machine"
  default     = "e2-small"
}

variable "pubsub_topics" {
  type        = list(any)
  description = "pubsub topics to create per name"
  default     = []
}

variable "artifactory_sa_email" {
  type        = string
  description = "already made service account to pull from cloud artifactory"
  default     = null
}

variable "scheduler_jobs" {
  type        = map(list(string))
  description = "scheduler jobs to create, schema: {'name': ['cron_pattern', 'time_zone']}"
  default     = {}
}

variable "google_secret_manager_keys" {
  type        = list(any)
  description = "all secret keys that present in secret manager for the application to fetch"
  default     = []
}

variable "old_service_accounts" {
  type        = list(any)
  description = "all service accounts that was already made for microservices"
  default     = []
}

variable "sql_disk_size" {
  type        = number
  description = "sql instance's disk size"
  default     = 100
}

variable "grafana_oauth_sa" {
  type        = string
  description = "service account for grafana google sso"
}

variable "sql_high_available" {
  type        = bool
  default     = false
  description = "whether to create replicas for the sql instance"
}

variable "sql_region" {
  type        = string
  description = "sql instance's region"
  default     = "us-central1"
}

variable "sql_databases" {
  type        = list(any)
  description = "sql instance's databases"
  default     = []
}

variable "sql_tier" {
  type        = string
  description = "sql instance machine"
  default     = "db-custom-4-26624"
}
