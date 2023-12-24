region = "us-east-2"
vpc_name = "eks-vpc"
vpc_cidr = "192.168.21.0/24"
internet_gw_name = "eks-gw"
subnet1 ={
    name = "eks-subnet1"
    cidr_block = "192.168.21.0/25"
    availability_zone = "us-east-2a"

}
subnet2 ={
    name = "eks-subnet2"
    cidr_block = "192.168.21.128/25"
    availability_zone = "us-east-2b"

}
eip = "eks-eip"
nat_gw_name = "eks-nat"
rt1_name = "eks_public_subnet_route_table"
rt2_name = "eks_private_subnet_route_table"
