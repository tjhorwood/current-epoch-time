# API Endpoint Deployment Instructions

This guide will walk you through the steps to deploy a Flask application on AWS EC2 instance which returns the current epoch time.

## Prerequisites

- Authenticated to an AWS Account with administrator access
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

## Update Terraform Variables

```bash
cd terraform
vim main.tf
```

## Run Deploy Script

```bash
chmod +x deploy.sh
./deploy.sh
```
