#!/bin/bash

# Exit on any error
set -e

# Pull latest code
git pull origin main

# Load environment variables from AWS Parameter Store
export ECR_REGISTRY=$(aws ssm get-parameter --name "/app/ecr/registry" --query "Parameter.Value" --output text)
export ECR_REPOSITORY_BACKEND=$(aws ssm get-parameter --name "/app/ecr/backend-repo" --query "Parameter.Value" --output text)
export ECR_REPOSITORY_FRONTEND=$(aws ssm get-parameter --name "/app/ecr/frontend-repo" --query "Parameter.Value" --output text)
export IMAGE_TAG=$(aws ssm get-parameter --name "/app/image-tag" --query "Parameter.Value" --output text)

# Load RDS credentials from AWS Secrets Manager
RDS_SECRETS=$(aws secretsmanager get-secret-value --secret-id app/rds/credentials --query "SecretString" --output text)
export RDS_HOSTNAME=$(echo $RDS_SECRETS | jq -r .hostname)
export RDS_USERNAME=$(echo $RDS_SECRETS | jq -r .username)
export RDS_PASSWORD=$(echo $RDS_SECRETS | jq -r .password)
export RDS_DB_NAME=$(echo $RDS_SECRETS | jq -r .dbname)
export RDS_PORT=$(echo $RDS_SECRETS | jq -r .port)

# Login to ECR
aws ecr get-login-password --region $(aws configure get region) | docker login --username AWS --password-stdin $ECR_REGISTRY

# Pull and run the containers
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d

# Clean up old images
docker image prune -f