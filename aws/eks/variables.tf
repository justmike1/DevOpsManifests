variable "cluster_addons" {
  description = "Which cluster addons should we create"
  type        = any
  default = {
    coredns = {
      version           = "latest"
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {
      version           = "latest"
      resolve_conflicts = "OVERWRITE"
    }
    vpc-cni = {
      version           = "latest"
      resolve_conflicts = "OVERWRITE"
    }
  }
}

variable "enable_addons" {
  description = "If to enable addons like github runner"
  type        = number
  default     = 0
}

variable "num_zones" {
  description = "How many zones should we utilize for the eks nodes"
  type        = number
  default     = 2
}

variable "k8s_version" {
  description = "Which version of k8s to install by default"
  type        = string
  default     = "1.23"
}

variable "cluster_name" {
  description = "k8s cluster name"
  type        = string
  default     = "eks"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.137.0.0/16"
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "eks-vpc"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "name_prefix" {
  type        = string
  description = "Prefix to be used on each infrastructure object Name created in AWS."
  default     = "eks"
}

variable "admin_users" {
  type        = list(string)
  description = "List of Kubernetes admins"
  default     = ["mike"]
}

variable "developer_users" {
  type        = list(string)
  description = "List of Kubernetes developers"
  default     = ["api-user"]
}

variable "domain_name" {
  type        = string
  description = "CI ingress domain name"
  default     = "domain.eks.com"
}
