provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "eks" {
  source = "../../"

  cluster_name       = var.cluster_name
  kubernetes_version = "1.32"

  vpc_id             = data.aws_vpc.default.id
  private_subnet_ids = data.aws_subnets.private.ids

  enable_node_group_main         = true
  node_group_main_instance_types = ["t3.medium"]
  node_group_main_scaling = {
    min     = 1
    max     = 3
    desired = 1
  }

  enable_cluster_autoscaler = true
  enable_metrics_server     = true
  enable_kube_state_metrics = false

  enable_node_group_spot     = false
  enable_node_group_critical = false
  enable_node_group_graviton = false

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
