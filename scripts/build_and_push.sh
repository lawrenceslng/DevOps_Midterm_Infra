#!/bin/bash
APP_REPO_PATH=$1

# Authenticate with AWS ECR
# aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

# Build the frontend Docker image
docker build -t devops-midterm-frontend:latest -t devops-midterm-frontend:"$TAG" -f "$APP_REPO_PATH/client/Dockerfile" "$APP_REPO_PATH"
# Build the backend Docker image
docker build --target=production -t devops-midterm-backend:latest -t devops-midterm-backend:"$TAG" "$APP_REPO_PATH/server"

# Tag and push the image to ECR
docker tag devops-midterm-frontend:latest "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/midterm-frontend:latest"
docker tag devops-midterm-frontend:"$TAG" "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/midterm-frontend:$TAG"

docker tag devops-midterm-backend:latest "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/midterm-backend:latest"
docker tag devops-midterm-backend:"$TAG" "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/midterm-backend:$TAG"

docker push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/midterm-frontend:latest"
docker push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/midterm-frontend:$TAG"

docker push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/midterm-backend:latest"
docker push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/midterm-backend:$TAG"

echo "Docker images successfully pushed to ECR."