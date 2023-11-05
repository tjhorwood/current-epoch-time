variable "name" {
  type    = string
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "s3_bucket" {
  type    = string
}

variable "s3_key" {
  type    = string
}

variable "subnet_ids" {
  type    = list(string)
}

variable "vpc_id" {
  type    = string
}