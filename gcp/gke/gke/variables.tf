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

variable "enable_runner" {
  description = "enable github runner"
  type        = number
  default     = 0
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

variable "machine_type" {
  type        = string
  description = "cluster's node machines"
  default     = "e2-small"
}

variable "sql_disk_size" {
  type        = number
  description = "sql instance's disk size"
}

variable "sql_region" {
  type        = string
  description = "sql instance's region"
}

variable "sql_databases" {
  type        = list(any)
  description = "sql instance's databases"
}

variable "sql_tier" {
  type        = string
  description = "sql instance machine"
  default     = "db-custom-4-26624"
}
