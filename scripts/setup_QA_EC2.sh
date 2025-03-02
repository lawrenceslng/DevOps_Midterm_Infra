#!/bin/bash

docker compose down || true

# Stop nginx to prevent conflicts
sudo systemctl stop nginx || true

# Authenticate Docker with AWS ECR
aws ecr get-login-password --region "$AWS_ACCOUNT_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_ACCOUNT_REGION.amazonaws.com"

# Pull the latest images
docker pull "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_ACCOUNT_REGION.amazonaws.com/midterm-frontend:latest"
docker compose pull

# Extract frontend files
docker run -d --name temp-container "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_ACCOUNT_REGION.amazonaws.com/midterm-frontend:latest"
sudo rm -rf /var/www/frontend  # Remove old files
sudo mkdir -p /var/www/frontend
docker cp temp-container:/usr/share/nginx/html/. ./contents
docker rm -f temp-container  # Clean up

sudo cp -r ./contents/* /var/www/frontend
rm -rf ./contents

# Start the backend service
docker compose up -d

# Restart Nginx
sudo systemctl restart nginx

# Wait for services to be ready
sleep 5