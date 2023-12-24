
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}
terraform {
  backend "s3" {
    bucket = "terraform-statefile-s3-aws"
    key    = "state/eks-cluster.tfstate"
    region = "us-east-2"
  }
}

# resource "aws_iam_role" "eks-iam-role" {
#  name = "eks-iam-role"

#  path = "/"

#  assume_role_policy = <<EOF
# {
#  "Version": "2012-10-17",
#  "Statement": [
#   {
#    "Effect": "Allow",
#    "Principal": {
#     "Service": "eks.amazonaws.com"
#    },
#    "Action": "sts:AssumeRole"
#   }
#  ]
# }
# EOF

# 

#Retrieving the VPC and subnet details 
data "aws_vpc" vpc {
    filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}
data "aws_subnet" "subnet1" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = [var.subnet1_name]
  }
}
data "aws_subnet" "subnet2" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = [var.subnet2_name]
  }
}

#creating IAM role for EKS cluster
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "eks-iam-role" {
  name               = "eks-cluster-example"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
#Attaching AmazonEKSClusterPolicy to the  IAM role
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role    = aws_iam_role.eks-iam-role.name
}
# resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-EKS" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#  role    = aws_iam_role.eks-iam-role.name
# }
#creating eks cluster
resource "aws_eks_cluster" "eks" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks-iam-role.arn

  vpc_config {
    subnet_ids = [data.aws_subnet.subnet1.id, data.aws_subnet.subnet2.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    # aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
  tags = {
    Name = var.eks_cluster_name
    region = var.region
  }
}

output "endpoint" {
  value = aws_eks_cluster.eks.endpoint
}
#Creating IAM for Node group
resource "aws_iam_role" "eks-nodes" {
  name = "eks-node-group-role"

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
#Attaching AmazonEKSWorkerNodePolicy,AmazonEKS_CNI_Policy and AmazonEC2ContainerRegistryReadOnly to the IAM role
resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       =  aws_iam_role.eks-nodes.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       =  aws_iam_role.eks-nodes.name
}
#creating node group for EKS
resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks-nodes.arn
  subnet_ids      = [data.aws_subnet.subnet1.id,data.aws_subnet.subnet2.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}