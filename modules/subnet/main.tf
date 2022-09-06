resource "aws_subnet" "myprac-subnet-1" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name = "${var.env_prefix}-subnet-1"
    }
}

/*resource "aws_route_table" "myprac-route-table" {
    vpc_id = var.vpc_id
    route {
        cidr_block = "0.0.0.0/0" #要创建连接外网的route
        gateway_id = aws_internet_gateway.myprac-igw.id #需要打开gateway id在下面创建
    }
    tags = {
        Name: "${var.env_prefix}-rtb"
    }
}*/

resource "aws_internet_gateway" "myprac-igw" {
    vpc_id = var.vpc_id #创建指定vpc的gateway
    tags = {
        Name = "${var.env_prefix}-igw"
    }
}

/*resource "aws_route_table_association" "associate-rtb-subent" {
    subnet_id = aws_subnet.myprac-subnet-1.id #要连接的subnet
    route_table_id = aws_route_table.myprac-route-table.id #要做asociate的rtb
}*/

resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = var.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = aws_internet_gateway.myprac-igw.id
    }
    tags ={
        Name = "${var.env_prefix}-main-rtb"
    }
}