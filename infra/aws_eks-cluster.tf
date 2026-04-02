module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name                   = "${var.deployment_name}-${random_string.unique_id.result}"
  kubernetes_version     = "1.30"
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.private_subnets
  endpoint_public_access = true

  create_security_group = false
  create_node_security_group    = false

  eks_managed_node_groups = {
    one = {
      name           = "${var.deployment_name}-ng"
      instance_types = ["t3a.large"]
      ami_type       = "AL2023_x86_64_STANDARD"

      use_custom_launch_template = false
      create_launch_template     = false

      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }
}