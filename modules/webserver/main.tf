/*resource "aws_security_group" "myprac-sg" {
    name = "myprac-sg"
    vpc_id = aws_vpc.myprac-vpc.id*/

#上面是创建新的SG 下面是用默认的 只需一点点改动

resource "aws_default_security_group" "default-sg" {
    vpc_id = var.vpc_id
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
        values = [var.image_name] 
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

/*resource "aws_key_pair" "ssh-key" {
    key_name = "0906-tfprac-key-pair"
    public_key = file(var.public_key_location)
}*/

resource "aws_instance" "myprac-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type 
    
    #下面三个是optional 如果不设置的话会在默认的VPC里面设置 想要换VPC的话就要设置 不用指明VPC因为子网在那个VPC下
    subnet_id = var.subnet_id 
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.avail_zone #这一步可有可无 also之前子网设置过了

    associate_public_ip_address = true #需要server有public ip因为要用网页访问或SSH
    key_name = "0906-tfprac-key-pair"

    #user_data = file("entry-script.sh") 前提是这个脚本在这个webserver路径下

    tags = {
        Name = "${var.env_prefix}-server"
    }
}