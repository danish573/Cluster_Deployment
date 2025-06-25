data "aws_subnets" "available_aws_subnets" {
  filter {
    name   = "tag:Name"
    values = ["our-public-*"]
  }
}

resource "aws_eks_cluster" "proj_cluster" {
  name     = "proj-cluster"
  role_arn = aws_iam_role.proj.arn

  vpc_config {
    subnet_ids = data.aws_subnets.available_aws_subnets.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.proj_amazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.proj_amazonEKSVPCResourceController,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.proj_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.proj_cluster.certificate_authority[0].data
}

resource "aws_eks_node_group" "node_grp" {
  cluster_name    = aws_eks_cluster.proj_cluster.name
  node_group_name = "proj-node-group"
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = data.aws_subnets.available_aws_subnets.ids
  capacity_type   = "ON_DEMAND"
  disk_size       = 20
  instance_types  = ["t2.micro"]
  labels          = tomap({ env = "dev" })

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.amazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.amazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.amazonEC2ContainerRegistryReadOnly
  ]
}
