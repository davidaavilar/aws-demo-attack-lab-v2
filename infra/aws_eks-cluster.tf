module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                   = "${var.deployment_name}-${random_string.unique_id.result}"
  kubernetes_version     = "1.30"
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnets
  endpoint_public_access = true

  eks_managed_node_groups = {
    one = {
      name           = "${var.deployment_name}-ng1"
      instance_types = ["t3a.large"]

      ami_type = "AL2023_x86_64_STANDARD"

      min_size     = 2
      max_size     = 3
      desired_size = 1
    }
  }
}