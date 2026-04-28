provider "aws" {
  region = "ap-south-1"
}

module "network" {
  source = "./modules/vpc"

  vpc_cidr        = "10.1.0.0/16"
  public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets = ["10.1.3.0/24", "10.1.4.0/24"]
  azs             = ["ap-south-1a", "ap-south-1b"]
}

module "loadbalancer" {
  source = "./modules/alb"

  vpc_id         = module.network.vpc_id
  public_subnets = module.network.public_subnets
}

module "compute" {
  source = "./modules/ec2"

  vpc_id           = module.network.vpc_id
  private_subnets  = module.network.private_subnets
  target_group_arn = module.loadbalancer.target_group_arn
  alb_sg           = module.loadbalancer.alb_sg

  ami              = var.ami
  instance_type    = var.instance_type
  desired_capacity = var.desired_capacity
}