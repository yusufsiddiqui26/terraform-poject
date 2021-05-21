
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name = "${var.env_prefix}-vpc"
    }
}

module "myapp-subnet" {
  source = ".\\modules\\subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

module "myapp-server" {
  source = ".\\modules\\webserver"
  image_name = var.image_name
  vpc_id = aws_vpc.myapp-vpc.id
  my_ip = var.my_ip
  env_prefix = var.env_prefix
  public_kay_location = var.public_kay_location
  instance_type = var.instance_type
  subnet_id = module.myapp-subnet.subnet.id
  docker_script = var.docker_script
  avail_zone = var.avail_zone
}