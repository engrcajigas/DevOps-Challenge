terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region     = var.region
  profile    = var.profile
}

locals {
  tag_name_prefix = "devops-challenge"
  az1             = "${var.region}a"
  az2             = "${var.region}b"
}

module "s3" {
  source          = "./modules/s3"
  tag_name_prefix = local.tag_name_prefix
}

module "iam" {
  source          = "./modules/iam"
  tag_name_prefix = local.tag_name_prefix
  s3_bucket_name  = module.s3.s3_bucket.id
}

module "vpc" {
  source               = "./modules/vpc"
  tag_name_prefix      = local.tag_name_prefix
  az1                  = local.az1
  az2                  = local.az2
  vpc_cidr             = "10.0.0.0/16"
  public_subnet1_cidr  = "10.0.1.0/24"
  public_subnet2_cidr  = "10.0.2.0/24"
  private_subnet1_cidr = "10.0.3.0/24"
  private_subnet2_cidr = "10.0.4.0/24"
}

module "alb" {
  source            = "./modules/alb"
  tag_name_prefix   = local.tag_name_prefix
  vpc               = module.vpc.vpc
  vpc_id            = module.vpc.vpc.id
  public_subnet1_id = module.vpc.public_subnet1.id
  public_subnet2_id = module.vpc.public_subnet2.id
}

module "asg" {
  source               = "./modules/asg"
  tag_name_prefix      = local.tag_name_prefix
  iam_instance_profile = module.iam.iam_instance_profile.id
  vpc_id               = module.vpc.vpc.id
  private_subnet1_id   = module.vpc.private_subnet1.id
  private_subnet2_id   = module.vpc.private_subnet2.id
  instance_type        = "t2.micro"
  #key_name              = "terraform"
  security_group_alb_id = module.alb.security_group_alb.id
  alb                   = module.alb.alb
  alb_target_group      = module.alb.alb_target_group
}

output "alb_url" {
  value = "http://${module.alb.alb.dns_name}"
}

