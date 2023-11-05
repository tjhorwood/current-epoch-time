variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = [] # You can provide a default list of subnet IDs here if desired
}

variable "vpc_id" {
  description = "VPC ID you would like to use"
  type        = string
}