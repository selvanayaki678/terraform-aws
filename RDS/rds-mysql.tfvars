region = "us-east-2"
rds_vpc_name = "rds-vpc"
vpc_cidr = "192.168.20.0/24"
internet_gw_name = "rds-internet-gw"
subnet1 = {
  name = "rds-subnet1"
  cidr = "192.168.20.0/25"
  az = "us-east-2a"
}
subnet2 = {
  name = "rds-subnet2"
  cidr = "192.168.20.128/25"
  az = "us-east-2b"
}
rt1_name = "public_subnet_route_table"
security_group_name = "rds-mysql-security-group"
rds = {
  name = "mysql-crud-rds"
  storage = 5
  engine_version = "8.0"
  username =  "admin"
  password = "admin123"
  public_access = true
}