
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

resource "aws_db_instance" "my-sql" {
  allocated_storage    = 5
  db_name              = "mysqdbcrud"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "admin@123"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  publicly_accessible = true
  storage_type ="standard"
  

}
