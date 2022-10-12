variable "project_id" {
  type        = string
  description = "name of the project in google cloud"
}

variable "domain" {
  type        = string
  description = "domain of the cluster"
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

variable "environment" {
  type        = string
  description = "cluster's env"
}

variable "enable_monitoring" {
  type        = number
  description = "deploy monitoring stack (grafana + prom)"
  default     = 0
}

variable "source_path" {
  type        = string
  description = "utilize root folder when applying from env folder"
  default     = "../../gke"
}

variable "machine_type" {
  type        = string
  description = "cluster's node machines"
  default     = "e2-small"
}
