#!/bin/bash

# Required environment variables:
# PUBLIC_IP - EC2 instance public IP
# AWS_ACCOUNT_ID - AWS account ID
# AWS_ACCOUNT_REGION - AWS region

# Decode SSH Key
echo "$EC2_SSH_PRIVATE_KEY" | base64 --decode > key.pem
chmod 600 key.pem

# Create a temporary directory for deployment files
mkdir -p deploy

# ls -l app-repo/client/build

# Copy frontend build
cp -r app-repo/client/build deploy/frontend

# Copy backend code
cp -r app-repo/server deploy/backend
cp app-repo/setup.sql deploy/

# Copy docker-compose, nginx config, and scripts
# cp infra/configurations/docker-compose.prod.yml deploy/
cp infra/configurations/docker-compose.temp.yml deploy/docker-compose.yml
cp infra/configurations/temp-ec2-nginx.conf deploy/nginx.conf
# cp infra/configurations/temp-ec2-nginx.conf_OLD deploy/
cp infra/scripts/setup_ec2.sh deploy/
cp infra/scripts/local_smoke_test.sh deploy/

# # Create .env file for docker-compose
# cat > deploy/.env << EOL
# ECR_REGISTRY=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_ACCOUNT_REGION}.amazonaws.com
# ECR_REPOSITORY_FRONTEND=midterm-frontend
# ECR_REPOSITORY_BACKEND=midterm-backend
# IMAGE_TAG=latest
# EOL

# Copy all files to EC2
scp -i key.pem -o StrictHostKeyChecking=no -r deploy/* ec2-user@${PUBLIC_IP}:/home/ec2-user/