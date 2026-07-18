provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {

cidr_block = "10.0.0.0/16"

tags = {
 Name = "pgsn-vpc"
}

}
resource "aws_subnet" "public" {

vpc_id = aws_vpc.main.id

cidr_block = "10.0.1.0/24"

map_public_ip_on_launch = true


tags = {
 Name="public-subnet"
}

}

resource "aws_internet_gateway" "igw" {

vpc_id = aws_vpc.main.id


tags={
 Name="main-igw"
}

}

resource "aws_route_table" "public_rt" {

vpc_id = aws_vpc.main.id


route {

cidr_block="0.0.0.0/0"

gateway_id=aws_internet_gateway.igw.id

}


}

resource "aws_route_table_association" "public_assoc" {


subnet_id = aws_subnet.public.id


route_table_id = aws_route_table.public_rt.id


}

resource "aws_security_group" "app_sg" {


vpc_id = aws_vpc.main.id


ingress {


from_port=22

to_port=22

protocol="tcp"

cidr_blocks=["0.0.0.0/0"]

}


ingress {


from_port=3000

to_port=3000

protocol="tcp"

cidr_blocks=["0.0.0.0/0"]

}



egress {


from_port=0

to_port=0

protocol="-1"

cidr_blocks=["0.0.0.0/0"]

}


}


resource "aws_instance" "app_server" {


ami = var.ami_id


instance_type = var.instance_type


subnet_id = aws_subnet.public.id


vpc_security_group_ids = [
aws_security_group.app_sg.id
]


user_data = file("userdata.sh")


tags={

Name="PGSN-App-Server"

}


}