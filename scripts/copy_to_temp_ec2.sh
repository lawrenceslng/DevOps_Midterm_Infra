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

# Copy frontend build
cp -r app-repo/client/build deploy/frontend

# Copy backend code
cp -r app-repo/server deploy/backend
cp app-repo/setup.sql deploy/

# Copy docker-compose, nginx config, and scripts
cp infra/configurations/docker-compose.temp.yml deploy/docker-compose.yml
cp infra/configurations/temp-ec2-nginx.conf deploy/nginx.conf
cp infra/scripts/setup_temp_ec2.sh deploy/
cp infra/scripts/local_smoke_test.sh deploy/

# Create .env file for backend
cat > deploy/backend/.env << EOL
DB_HOST=$DB_HOST
DB_USER=$DB_USER
DB_PASSWORD=
DB_NAME=$DB_NAME
EOL

# Send Github Token to Temp EC2 for making requests
echo "$GITHUB_PAT" > deploy/github_token.txt

# Send AWS Credentials to Temp EC2 to auth for self-termination
echo "$AWS_ACCESS_KEY_ID" > deploy/aws_access_key_id.txt
echo "$AWS_SECRET_ACCESS_KEY" > deploy/aws_secret_access_key.txt
echo "$AWS_SESSION_TOKEN" > deploy/aws_session_token.txt
echo "$INSTANCE_ID" > deploy/current_instance_id.txt

# Copy all files to EC2
scp -i key.pem -o StrictHostKeyChecking=no -r deploy/* ec2-user@${PUBLIC_IP}:/home/ec2-user/