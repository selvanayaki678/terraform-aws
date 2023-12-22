

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
  region = "us-east-2"
}
terraform {
  backend "s3" {
    bucket = "selva-test-s3"
    key    = "state/rds-instance.tfstate"
    region = "us-east-2"
  }
}

#creating vpc for RDS instance
resource "aws_vpc" "main" {
  cidr_block = "192.168.20.0/24"
  enable_dns_hostnames = true
  tags = {
    Name = "rds-vpc"
  }
}
#We are going to create Public subnet, so it Internet gateway is required.
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}
#creating subnets
resource "aws_subnet" "rds-s1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.20.0/25"
  availability_zone = "us-east-2a"
  tags = {
    Name = "rds-subnet1"
  }
}
resource "aws_subnet" "rds-s2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.20.128/25"

  tags = {
    Name = "rds-subnet2"
  }
}
# creating route table for to route subnets traffic to internet gateway
resource "aws_route_table" "public_subnet_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "192.168.20.0/24"
    gateway_id = "local"
  } 
 route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
 }
  tags = {
    Name = "public_subnet_route_table"
  }
}
# Assciating the route table to the subnet
resource "aws_route_table_association" "rt_public_subnet1_ass" {
  subnet_id      = aws_subnet.rds-s1.id
  route_table_id = aws_route_table.public_subnet_rt.id
}
resource "aws_route_table_association" "rt_public_subnet2_ass" {
  subnet_id      = aws_subnet.rds-s2.id
  route_table_id = aws_route_table.public_subnet_rt.id
}
# Creating subnet group for RDS instance
resource "aws_db_subnet_group" "default" {
  name      = "rds-main"
  subnet_ids = [aws_subnet.rds-s1.id, aws_subnet.rds-s2.id]

  tags = {
    Name = "My DB subnet group"
  }
}
# Creating security group for RDS instace to allow all traffic
resource "aws_security_group" "example" {
  name        = "app-security-group"
  description = "To allow all traffic"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "example"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_all" {
  security_group_id = aws_security_group.example.id

   cidr_ipv4   = "0.0.0.0/0"
  # from_port   = 80
  ip_protocol = -1
  # to_port     = 80
}
#Creating RDS instance
resource "aws_db_instance" "my-sql" {
  allocated_storage    = 5
  db_name              = "mysqdbcrud"
  identifier           = "mysql-crud-rds"
  engine               = "mysql"
  engine_version       = "8.0"
  db_subnet_group_name  = aws_db_subnet_group.default.id
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "admin123"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible = true
  storage_type = "standard"
  vpc_security_group_ids = [aws_security_group.example.id]
  depends_on = [ aws_vpc_security_group_ingress_rule.allow_all ]
}

