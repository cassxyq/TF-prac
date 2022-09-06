provider "aws" {
    region = "ap-southeast-2"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone{}
variable env_prefix {}
variable my_ip{}

resource "aws_vpc" "myprac-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myprac-subnet-1" {
    vpc_id = aws_vpc.myprac-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

/*resource "aws_route_table" "myprac-route-table" {
    vpc_id = aws_vpc.myprac-vpc.id
    route {
        cidr_block = "0.0.0.0/0" #要创建连接外网的route
        gateway_id = aws_internet_gateway.myprac-igw.id #需要打开gateway id在下面创建
    }
    tags = {
        Name: "${var.env_prefix}-rtb"
    }
}*/

resource "aws_internet_gateway" "myprac-igw" {
    vpc_id = aws_vpc.myprac-vpc.id #创建指定vpc的gateway
    tags = {
        Name: "${var.env_prefix}-igw"
    }
}

/*resource "aws_route_table_association" "associate-rtb-subent" {
    subnet_id = aws_subnet.myprac-subnet-1.id #要连接的subnet
    route_table_id = aws_route_table.myprac-route-table.id #要做asociate的rtb
}*/

resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.myprac-vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = aws_internet_gateway.myprac-igw.id
    }
    tags ={
        Name: "${var.env_prefix}-main-rtb"
    }
}

resource "aws_security_group" "myprac-securgroup" {
    name = "myprac-securgroup"
    vpc_id = aws_vpc.myprac-vpc.id

    ingress {
        from_port = 22
        to_port = 22 #from to 这里是设置对security开放的range 可以是0-1000 同是22代表只对port 22开放
        protocol = "tcp"
        cidr_block = [var.my_ip] #哪些ip address range被允许access resource on port 22                       
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_block = ["0.0.0.0/0"]
    }
}
