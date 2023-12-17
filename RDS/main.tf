
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


resource "aws_vpc" "main" {
  cidr_block = "192.168.20.0/24"
  tags = {
    Name = "rds-vpc"
  }
}
resource "aws_subnet" "rds-s1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.20.0/25"

  tags = {
    Name = "rds-subnet1"
  }
}
resource "aws_subnet" "rds-s2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.20.127/25"

  tags = {
    Name = "rds-subnet2"
  }
}
resource "aws_db_subnet_group" "default" {
  name       = "rds-main"
  subnet_ids = [aws_subnet.rds-s1, aws_subnet.rds-s2.id]

  tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_db_instance" "my-sql" {
  allocated_storage    = 5
  db_name              = "mysql-db"
  engine               = "mysql"
  engine_version       = "8.0"
  db_subnet_group_name  = aws_db_subnet_group.default.id
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "admin@123"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible = true
  storage_type ="standard"
  

}
