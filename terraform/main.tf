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

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "subnet" {
  count                   = 4 # Create two subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true # For public access
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "route_table_association" {
  count          = length(aws_subnet.subnet)
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.route_table.id
}

module "ecr" {
  source = "./ecr"
  repository_name = "current-epoch-time"
}

module "ecs" {
  source = "./ecs"
  cluster_name = "current-epoch-time"
  ecr_repository_url = module.ecr.repository_url
  subnet_ids = aws_subnet.subnet.*.id
  vpc_id = aws_vpc.vpc.id
}