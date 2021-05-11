provider "aws" {
    region = "ap-northeast-1"
    profile = "admin"
}

variable "subnet1_cidr_block" {
    description = "define cidr block for subnet1 ex 10.0.10.0 24"
  
}
resource "aws_vpc" "development-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name: "development"
        Prod: "None"
    }
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.development-vpc.id
    cidr_block = var.subnet1_cidr_block
    availability_zone = "ap-northeast-1a"
    tags = {
        Name: "sub-1-dev"
    }
}

data "aws_vpc" "existing_vpc" {
    default = true
}

resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.existing_vpc.id
    cidr_block = "172.31.48.0/20"
    availability_zone = "ap-northeast-1a"
    tags = {
        Name: "sub-2-default"
    }
}

output "dev-vpc-id" {
  value = aws_vpc.development-vpc.id
}

output "dev-subnet1-id" {
    value = aws_subnet.dev-subnet-1.id 
}