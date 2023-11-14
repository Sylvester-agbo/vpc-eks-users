# this code works only in a local backend environment after creating the vpc
data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
}

resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "private-nodes"
  node_role_arn   = data.terraform_remote_state.network.outputs.node_role

  subnet_ids = [
    data.terraform_remote_state.network.outputs.private[0], data.terraform_remote_state.network.outputs.private[1]
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t2.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "devOps"
  }

  tags = {
    "k8s.io/cluster-autoscaler/demo"    = "owend"
    "k8s.io/cluster-autoscaler/enabled" = true

  }
}