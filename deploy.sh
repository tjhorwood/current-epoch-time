#!/bin/bash

# Stop script and ensure it fails if a command in a pipeline fails
set -euo pipefail

# Define script variables
## Static variables
AWS_REGION="us-east-1"
NAME="current-epoch-time"
TAG="latest"

## Dynamic variables
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
if [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "Unable to get AWS Account ID. Make sure you are authenticated."
  exit 1
fi
ECR_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECR_REPOSITORY_URL="${ECR_URL}/${NAME}"
TFSTATE_BUCKET_NAME="${NAME}-tfstate"

# Create S3 bucket to store Terraform state, if the AWS CLI is configured correctly, it will use the credentials.
echo "Creating S3 bucket to store Terraform state: ${TFSTATE_BUCKET_NAME}"
aws s3api create-bucket --bucket "${TFSTATE_BUCKET_NAME}" --region "${AWS_REGION}" >/dev/null 2>&1
aws s3api put-bucket-versioning --bucket "${TFSTATE_BUCKET_NAME}" --versioning-configuration Status=Enabled

# Initialize and apply ECR Terraform configuration
function init_and_apply_module() {
  dir=$1
  module=$2
  if [ -d "$dir" ]; then
    echo "Initializing and applying ${module} configuration in ${dir}"
    (cd "$dir" && terraform init && terraform plan -target=module.$module -out=plan.tfplan && terraform apply -auto-approve "plan.tfplan")
  else
    echo "Directory ${dir} does not exist."
    exit 1
  fi
}

init_and_apply_module terraform ecr

# Log into ECR
echo "Logging into ECR"
aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${ECR_URL}"

# Check if Docker daemon is running
if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon is not running"
  exit 1
fi

# Build, tag, and push image to ECR
echo "Building, tagging, and pushing image to ECR"
docker build -t "${NAME}" .
docker tag "${NAME}:${TAG}" "${ECR_REPOSITORY_URL}:${TAG}"
docker push "${ECR_REPOSITORY_URL}:${TAG}"

# Initialize and apply All Terraform configuration
function init_and_apply() {
  dir=$1
  if [ -d "$dir" ]; then
    echo "Initializing and applying Terraform configuration in ${dir}"
    (cd "$dir" && terraform init && terraform apply -auto-approve)
  else
    echo "Directory ${dir} does not exist."
    exit 1
  fi
}

init_and_apply terraform