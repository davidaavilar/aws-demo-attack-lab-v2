data "aws_caller_identity" "current" {}

output "current_principal_arn" {
  value = data.aws_caller_identity.current.arn
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${var.deployment_name}-${random_string.unique_id.result}"
  kubernetes_version = "1.30"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  addons = {
    vpc-cni = {
      most_recent = true
      before_compute = true
    }
    kube-proxy = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    default_v3 = {
      instance_types = ["t3a.large"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1

      ami_type = "AL2023_x86_64_STANDARD"

      capacity_type = "ON_DEMAND"

      use_custom_launch_template = false
      disk_size = 100
    }
    llm = {
      instance_types = ["g5.xlarge"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1

      ami_type       = "AL2023_x86_64_STANDARD"
      capacity_type  = "ON_DEMAND"

      use_custom_launch_template = false
      disk_size = 100

      labels = {
        workload = "llm"
      }
    }
  }
}