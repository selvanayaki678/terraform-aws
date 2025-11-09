variable "region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "vpc_name" {
  type        = string
  description = "Name tag for the VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "internet_gw_name" {
  type        = string
  description = "Name tag for the Internet Gateway"
}

variable "public_subnet1" {
  type = object({
    name              = string
    cidr_block        = string
    availability_zone = string
  })
}

variable "private_subnet1" {
  type = object({
    name              = string
    cidr_block        = string
    availability_zone = string
  })
}

variable "private_subnet2" {
  type = object({
    name              = string
    cidr_block        = string
    availability_zone = string
  })
}

variable "public_rt_name" {
  type        = string
  description = "Name tag for public route table"
}

variable "private_rt_name" {
  type        = string
  description = "Name tag for private route table"
}

variable "ec2_key_pair_name" {
  type = string
}