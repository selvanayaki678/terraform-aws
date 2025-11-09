terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
variable "region" {
  type = string
  default = "us-east-1"
}
provider "aws" {
  region = var.region
}
resource "aws_s3_bucket" "s3" {
  bucket = "terraform-statefile-s3-selva"

  tags = {
    Name        = "terraform-statefile-s3"
    Environment = "Dev"
  }
}