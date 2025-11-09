terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "terraform-statefile-s3-selva"
    key    = "state/vpc-eks.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}

# ----------------------
# VPC
# ----------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# ----------------------
# Internet Gateway
# ----------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.internet_gw_name
  }
}

# ----------------------
# Public Subnet (for NAT / ELB)
# ----------------------
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet1.cidr_block
  availability_zone       = var.public_subnet1.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name                          = var.public_subnet1.name
    "kubernetes.io/role/elb"      = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# ----------------------
# Private Subnets (for worker nodes & MCP)
# ----------------------
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet1.cidr_block
  availability_zone = var.private_subnet1.availability_zone

  tags = {
    Name                                 = var.private_subnet1.name
    "kubernetes.io/role/internal-elb"    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet2.cidr_block
  availability_zone = var.private_subnet2.availability_zone

  tags = {
    Name                                 = var.private_subnet2.name
    "kubernetes.io/role/internal-elb"    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# ----------------------
# Elastic IP for NAT
# ----------------------
resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = "nat-eip"
  }
}

# ----------------------
# NAT Gateway
# ----------------------
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "nat-gateway"
  }

  depends_on = [aws_internet_gateway.gw]
}

# ----------------------
# Route Table for Public Subnet
# ----------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = var.public_rt_name
  }
}

# Associate public subnet with public RT
resource "aws_route_table_association" "public_1_ass" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

# ----------------------
# Route Table for Private Subnets
# ----------------------
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = var.private_rt_name
  }
}

# Associate private subnets with private RT
resource "aws_route_table_association" "private_1_ass" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_2_ass" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}
