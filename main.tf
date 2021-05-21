terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "myapp-bucket-yss"
    key = "myapp/state.tfstate"
    region = "ap-northeast-1"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.avail_zone]
  public_subnets  = [var.subnet_cidr_block]
  public_subnet_tags = {Name = "${var.env_prefix}-subnet-1"}


  tags = {
    Name = "${var.env_prefix}-vpc"
    Terraform = "true"
    Environment = "dev"
  }
}

module "myapp-server" {
  source = ".\\modules\\webserver"
  image_name = var.image_name
  vpc_id = module.vpc.vpc_id
  my_ip = var.my_ip
  env_prefix = var.env_prefix
  public_kay_location = var.public_kay_location
  instance_type = var.instance_type
  subnet_id = module.vpc.public_subnets[0]
  docker_script = var.docker_script
  avail_zone = var.avail_zone
}