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
    key    = "state/eks-helm-nginx-ingress-controller.tfstate"
    region = "us-east-2"
  }
}


data "aws_eks_cluster" "example" {
  name = var.cluster_name
}

output "endpoint" {
  value = data.aws_eks_cluster.example.endpoint
}
# output "all" {
#     value =data.aws_eks_cluster.example
# }
output "kubeconfig-certificate-authority-data" {
  value = data.aws_eks_cluster.example.certificate_authority[0].data
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.example.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}
resource "helm_release" "nginx" {
  chart      = "${path.module}/ingress-nginx"
  name       = "nginx-ingress"
  namespace  = "nginx-ingress"
  atomic =  true 
  create_namespace = true
  # set {
  #   name = "controller.service.annotations"
  #   value = "service.beta.kubernetes.io/aws-load-balancer-type: nlb"
  # }
}