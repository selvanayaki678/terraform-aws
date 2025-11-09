region            = "us-east-1"
cluster_name      = "k8s-agent-cluster"
vpc_name          = "k8s-troubleshooting-vpc"
vpc_cidr          = "10.0.0.0/16"
internet_gw_name  = "k8s-troubleshooting-igw"

public_subnet1 = {
  name              = "public-subnet-1"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

private_subnet1 = {
  name              = "private-subnet-1"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}

private_subnet2 = {
  name              = "private-subnet-2"
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
}

public_rt_name  = "public-route-table"
private_rt_name = "private-route-table"
ec2_key_pair_name = "eks-worker-node-key-pair"
