terraform {
  required_version = ">= 0.12"
    backend "s3" {
      bucket = "myapp-bucket78"
      key = "myapp/state.tfstate"
      region = "us-east-1"
    }
  }




module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_blocks

  azs             = [var.avail_zone]
  public_subnets  = [var.subnet_cidr_blocks]
public_subnet_tags = {Name = "${var.env_prefix}-subnet-1"}
  

  tags = {
    Name = "$(var.env_prefix) -vpc"
  }
}

module "myapp-server" {
  source = "./modules/webservers"

  vpc_id        = module.vpc.vpc_id
  my_ip         = var.my_ip
  env_prefix    = var.env_prefix
  image_name    = var.image_name
  public_key    = var.public_key
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnets[0]
  avail_zone    = var.avail_zone


}






