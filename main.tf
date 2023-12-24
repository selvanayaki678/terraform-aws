
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

resource "aws_s3_bucket" "example" {
  bucket = "terraform-statefile-s3-aws"

  tags = {
    Name        = "My bucket"
    
  }
}