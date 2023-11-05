# API Endpoint Deployment Instructions

This guide will walk you through the steps to deploy a Flask application on AWS EC2 instance which returns the current epoch time.

## Prerequisites

- AWS Account with administrator access
- Terraform installed on your machine
- Docker installed on your machine

1. aws configure
2. create S3 terraform state bucket
3. create ECR repo
4. build image from Dockerfile
5. push image to ECR
6. run terraform
7. take output and curl for results

## Configure your connection to AWS

```bash
aws configure
```

## Create S3 bucket for Terraform state

```bash
aws s3api create-bucket --bucket current-epoch-time-tfstate --region us-east-1
aws s3api put-bucket-versioning --bucket current-epoch-time-tfstate --versioning-configuration Status=Enabled
```

## Initialize Terraform

```bash
cd terraform
terraform init
terraform plan -out=plan.tfplan
terraform apply "plan.tfplan"
```

## Create ECR repository

```bash
cd terraform/ecr
terraform init
terraform plan -out=plan.tfplan
terraform apply "plan.tfplan"
```

## Build and push Docker image to ECR repository

```bash
$(aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 652136470530.dkr.ecr.us-east-1.amazonaws.com)
docker build -t current-epoch-time .
docker tag current-epoch-time:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${TAG}
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}:${TAG}
```
