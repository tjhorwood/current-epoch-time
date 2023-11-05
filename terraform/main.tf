provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = var.s3_bucket
    key    = var.s3_key
    region = var.region
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