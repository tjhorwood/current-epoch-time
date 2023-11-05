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
  repository_name = "current-epoch-time"
}

module "ecs" {
  source = "./ecs"
  cluster_name = "current-epoch-time"
  ecr_repository_url = module.ecr.repository_url
  subnet_ids = ["subnet-cf603085", "subnet-2da82571", "subnet-f5fc7c92", "subnet-a89e1186", "subnet-141fcb2a", "subnet-25760c2a"]
  vpc_id = "vpc-7c9b4706"
}