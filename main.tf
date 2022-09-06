provider "aws" {
    region = "ap-southeast-2"
}

resource "aws_vpc" "myprac-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myprac-subnet-1" {
    vpc_id = aws_vpc.myprac-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
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
        Name = "${var.env_prefix}-igw"
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
        Name = "${var.env_prefix}-main-rtb"
    }
}

/*resource "aws_security_group" "myprac-sg" {
    name = "myprac-sg"
    vpc_id = aws_vpc.myprac-vpc.id*/

#上面是创建新的SG 下面是用默认的 只需一点点改动
resource "aws_default_security_group" "default-sg" {
    vpc_id = aws_vpc.myprac-vpc.id

    ingress {
        from_port = 22
        to_port = 22 #from to 这里是设置对security开放的range 可以是0-1000 同是22代表只对port 22开放
        protocol = "tcp"
        cidr_blocks = [var.my_ip] #哪些ip address range被允许access resource on port 22                       
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0 #0代表any
        to_port = 0
        protocol = "-1" #procotol的any是-1
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name = "${var.env_prefix}-default-sg" #若新建要改下标签
    }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true #要get most recent image version
    owners = ["amazon"]
    filter {
        name = "name" #要找的过滤条件是name
        values = ["amzn2-ami-hvm-*-x86_64-gp2"] #要找的值是名字带这些的 *是任意
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}


resource "aws_instance" "myprac-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type 
    
    #下面三个是optional 如果不设置的话会在默认的VPC里面设置 想要换VPC的话就要设置 不用指明VPC因为子网在那个VPC下
    subnet_id = aws_subnet.myprac-subnet-1.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.avail_zone #这一步可有可无 also之前子网设置过了

    associate_public_ip_address = true #需要server有public ip因为要用网页访问或SSH
    key_name = "0906-tfprac-key-pair"

    tags = {
        Name = "${var.env_prefix}-server"
    }
}