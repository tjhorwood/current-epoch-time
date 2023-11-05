provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "current-epoch-time-tfstate"
    key    = "ecs/terraform.tfstate"
    region = "us-east-1"
  }
}

module "ecr" {
  source = "./ecr"
  repository_name = var.name
}

module "ecs" {
  source = "./ecs"
  cluster_name = var.name
  ecr_repository_url = module.ecr.repository_url
  subnet_ids = var.subnet_ids
  vpc_id = var.vpc_id
}