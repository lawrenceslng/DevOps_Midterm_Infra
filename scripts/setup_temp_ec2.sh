#!/bin/bash

# Stop nginx installed on temp EC2 from running
sudo systemctl stop nginx

# Bring up application
docker compose up -d

# Wait for services to be ready
sleep 10