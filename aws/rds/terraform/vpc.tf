locals {
  cidrsubnet      = var.vpc_cidr
  private_subnets = [cidrsubnet(local.cidrsubnet, 4, 1), cidrsubnet(local.cidrsubnet, 4, 2), cidrsubnet(local.cidrsubnet, 4, 3)]
  public_subnets  = [cidrsubnet(local.cidrsubnet, 4, 4), cidrsubnet(local.cidrsubnet, 4, 5), cidrsubnet(local.cidrsubnet, 4, 6)]
  single_nat_gateway = false
  num_zones = 1
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.5"

  name = "${var.project}-vpc"
  cidr = local.cidrsubnet

  azs              = slice(data.aws_availability_zones.available.names, 0, local.num_zones)
  private_subnets  = slice(local.private_subnets, 0, local.num_zones)
  public_subnets   = slice(local.public_subnets, 0, local.num_zones)
  database_subnets = slice(local.database_subnets, 0, local.num_zones)

  enable_nat_gateway     = true
  single_nat_gateway     = local.single_nat_gateway
  one_nat_gateway_per_az = true

  public_subnet_tags = {
    "public_sn" = "1"
  }

  private_subnet_tags = {
    "private_sn_internal" = "1"
  }

  tags = var.tags

}