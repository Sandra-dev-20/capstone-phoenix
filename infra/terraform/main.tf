data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "network" {
  source       = "./modules/network"
  project_name = var.project_name
  environment  = var.environment
}

module "security_group" {
  source       = "./modules/security_group"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id
  my_ip        = var.my_ip
}

module "compute" {
  source            = "./modules/compute"
  project_name      = var.project_name
  environment       = var.environment
  instance_type     = var.instance_type
  key_name          = var.key_name
  subnet_ids        = module.network.public_subnet_ids
  security_group_id = module.security_group.nodes_sg_id
  ami_id            = data.aws_ami.ubuntu.id
}

