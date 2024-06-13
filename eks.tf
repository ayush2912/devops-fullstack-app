provider "aws" {
  region = "us-east-1" 
}

resource "aws_iam_role" "my_cluster" {
  name = "my_cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "my_cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.my_cluster.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.my_cluster.name
}



resource "aws_cloudwatch_log_group" "eks_cluster_logs" {
  name = "/aws/eks/my-cluster"
}

resource "aws_eks_cluster" "my_cluster" {
  name     = "my-cluster"
  role_arn = aws_iam_role.my_cluster.arn
  version  = "1.29"
  vpc_config {
    subnet_ids = [var.subnet_id_1, var.subnet_id_2,var.subnet_id_3,var.subnet_id_4]

    endpoint_public_access = true
    endpoint_private_access = true
  }
 
     
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.my_cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController
    
  ]
}

resource "aws_security_group" "eks_node_group_sg" {
  name        = "eks-node-group-sg"
  description = "Security Group for EKS Node Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.my_cluster.version}/amazon-linux-2/recommended/release_version"
}
resource "aws_iam_role" "my_nodes" {
  name = "eks-node-group-my_nodes"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "my_nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.my_nodes.name
}

resource "aws_iam_role_policy_attachment" "my_nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.my_nodes.name
}

resource "aws_iam_role_policy_attachment" "my_nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.my_nodes.name
}

resource "aws_eks_node_group" "my_nodes" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "my_nodes"
  node_role_arn   = aws_iam_role.my_nodes.arn
  subnet_ids      = [var.subnet_id_1, var.subnet_id_2]
  release_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
  instance_types  = ["t3.large"]
  capacity_type   = "ON_DEMAND"

  labels = {
    "Name" = "my-cluster"
  }

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  remote_access {
    ec2_ssh_key = "eks-test1"
    source_security_group_ids = [aws_security_group.eks_node_group_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.my_nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.my_nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.my_nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
}
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.my_cluster.name
  addon_name   = "coredns"
  addon_version = "v1.11.1-eksbuild.9"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.my_cluster.name
  addon_name   = "kube-proxy"
  addon_version = "v1.29.1-eksbuild.2"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.my_cluster.name
  addon_name   = "vpc-cni"
  addon_version = "v1.18.1-eksbuild.3"
}


