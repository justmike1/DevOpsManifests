variable "network_interface_id" {
  type    = string
  default = "network_id_from_aws"
}

variable "ami" {
  type    = string
  default = "ami-005e54dee72cc1d00"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "vpc_cidr" {
  description = "Cidr of the vpc we will create in the format of X.X.X.X/XX"
  type        = string
}

variable "project" {
  default     = "template"
  description = "Name of the project - this is used to generate names for resources"
  type        = string
}