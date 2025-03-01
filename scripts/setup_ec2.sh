#!/bin/bash

# Install Docker and Docker Compose
# sudo yum update -y
# sudo yum install -y docker
# sudo service docker start
# sudo usermod -a -G docker ec2-user
# sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# sudo chmod +x /usr/local/bin/docker-compose

# # Start services
# cd /home/ec2-user
sudo systemctl stop nginx

docker compose up

# Wait for services to be ready
sleep 30