provider "aws" {
    region = "ap-northeast-1"
    profile = "admin"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable "my_ip" {}
variable "instance_type" {}
variable "key_pair" {}
variable "public_kay_location" {}
variable "docker_script" {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name = "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
      Name = "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
      Name = "${var.env_prefix}-igw"
    }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
   route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
      Name = "${var.env_prefix}-main-route-tbl"
    }
}

resource "aws_default_security_group" "default-sg" {
  #  name = "myapp-sg"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress  {
      cidr_blocks = [ var.my_ip ]
      description = "defining ssh access on my ip"
      from_port = 22
      protocol = "tcp"
      to_port = 22
      }

     ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "allow web port on any destination"
      from_port = 8080
      protocol = "tcp"
      to_port = 8080 
      } 

    egress {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "allow user to request any traffic from server"
      from_port = 0
      protocol = "-1"
      to_port = 0
      prefix_list_ids = []
      }

    tags = {
      Name: "${var.env_prefix}-default-sg"
    }  
}

data "aws_ami" "latest-amazon-ami" {
  most_recent = true
  owners = ["amazon"]
  
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name = "tokyo-key"
  public_key = file(var.public_kay_location)
  
}

resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-ami.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  #availability_zone = val.avail_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name
  user_data = file(var.docker_script)

   tags = {
      Name: "${var.env_prefix}-server"
    }  
}

output "public_ip_addr" {
  value = aws_instance.myapp-server.public_ip  
}
