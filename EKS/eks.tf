locals {
  enabled_cluster_logs = ["api", "audit", "controllerManager", "scheduler", "authenticator"]
  partition       = data.aws_partition.current.partition
}

resource "aws_ebs_encryption_by_default" "ebs_encryption" {
  enabled = true
}

resource "aws_kms_key" "eks" {
  description = "EKS Secret Encryption Key"
}


module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 18.0"
  cluster_name    = var.cluster_name
  cluster_version = var.k8s_version
  subnet_ids      = slice(module.vpc.private_subnets, 0, 2)
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = "true"


  cluster_enabled_log_types = local.enabled_cluster_logs

  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks.arn
      resources        = ["secrets"]
    }
  ]

  tags = {
    Environment = "ci"
    Terraform   = "True"
    "karpenter.sh/discovery" = var.cluster_name
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
     # Control plane invoke Karpenter webhook
    ingress_karpenter_webhook_tcp = {
      description                   = "Control plane invoke Karpenter webhook"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }
  
  eks_managed_node_groups = {
    worker-ci = {
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"

      min_size     = 1
      max_size     = 10
      desired_size = 1

      iam_role_additional_policies = [
        # Required by Karpenter
        "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]

      tags = {
        instance-type  = "on-demand-large"
      }
    }
  }
}

resource "aws_eks_addon" "this" {
  for_each = { for k, v in var.cluster_addons : k => v }

  cluster_name = var.cluster_name
  addon_name   = try(each.value.name, each.key)

  addon_version            = lookup(each.value, "addon_version", null)
  resolve_conflicts        = lookup(each.value, "resolve_conflicts", null)
  service_account_role_arn = lookup(each.value, "service_account_role_arn", null)

  lifecycle {
    ignore_changes = [
      modified_at
    ]
  }
  tags = { Terraform = "True" }

  depends_on = [module.eks]
}
