
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
    key    = "state/vpc-eks.tfstate"
    region = "us-east-2"
  }
}

#creating vpc for EKS cluster 
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}
#If We are going to create Public subnet, so it Internet gateway is required.
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.internet_gw_name
  }
}
#creating public subnet
resource "aws_subnet" "rds-s1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet1.cidr_block
  availability_zone = var.subnet1.availability_zone
  map_public_ip_on_launch=true
  tags = {
    Name = var.subnet1.name
    "kubernetes.io/role/elb" ="1"
  }
}
resource "aws_subnet" "rds-s2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet2.cidr_block
  availability_zone = var.subnet2.availability_zone
  tags = {
    Name = var.subnet2.name
    # "kubernetes.io/role/internal-elb"="1"
  }
}
# resource "aws_eip" "eip" {
#   domain           = "vpc"
# #   public_ipv4_pool = "ipv4pool-ec2-012345"
#  tags = {
#     Name = var.eip
#   }
# }

# resource "aws_nat_gateway" "nat" {
#   allocation_id = aws_eip.eip.id
#   subnet_id     = aws_subnet.rds-s1.id

#   tags = {
#     Name = var.nat_gw_name
#   }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  #depends_on = [aws_internet_gateway.example]
# }
# creating route table for to route subnets traffic to internet gateway
resource "aws_route_table" "public_subnet_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.vpc_cidr
    gateway_id = "local"
  } 
 route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
 }
  tags = {
    Name = var.rt1_name
  }
}
# Assciating the route table to the public subnet
resource "aws_route_table_association" "rt_public_subnet1_ass" {
  subnet_id      = aws_subnet.rds-s1.id
  route_table_id = aws_route_table.public_subnet_rt.id
}
resource "aws_route_table_association" "rt_public_subnet2_ass" {
  subnet_id      = aws_subnet.rds-s2.id
  route_table_id = aws_route_table.public_subnet_rt.id
}

# resource "aws_route_table" "private_subnet_rt" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = var.vpc_cidr
#     gateway_id = "local"
#   } 
#  route {
#   cidr_block = "0.0.0.0/0"
#   # gateway_id = aws_nat_gateway.nat.id
#  }
#   tags = {
#     Name = var.rt2_name
#   }
# }
# Assciating the route table to the private subnet
# resource "aws_route_table_association" "rt_private_subnet1_ass" {
#   subnet_id      = aws_subnet.rds-s2.id
#   route_table_id = aws_route_table.private_subnet_rt.id
# }

