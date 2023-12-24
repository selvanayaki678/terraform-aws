variable "region" {
  type = string
}
variable "rds_vpc_name" {
  type =  string
}
variable "vpc_cidr" {
  type = string
}
variable "internet_gw_name" {
  type= string
}
variable "subnet1" {
  type = object({
    name = string
    cidr = string
    az= string
  })
}
variable "subnet2" {
  type = object({
    name = string
    cidr = string
    az= string
  })
}
variable "rt1_name" {
  type = string
}
variable "security_group_name" {
  type = string
}
variable "rds" {
  type = object({
    name = string
    storage = number
    engine_version = string
    username = string
    password = string
    public_access = bool
  })
}