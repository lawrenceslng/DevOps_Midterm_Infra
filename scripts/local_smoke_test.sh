#!/bin/bash

# GitHub and Repository Configuration
GITHUB_TOKEN=$(cat github_token.txt) # might need to see if $ is somehow prepended
AWS_ACCESS_KEY_ID=$(cat aws_access_key_id.txt) # might need to see if $ is somehow prepended
AWS_SECRET_ACCESS_KEY=$(cat aws_secret_access_key.txt) # might need to see if $ is somehow prepended
AWS_SESSION_TOKEN=$(cat aws_session_token.txt) # might need to see if $ is somehow prepended
INSTANCE_ID=$(cat current_instance_id.txt)

# Function to trigger GitHub workflow
trigger_workflow() {
  local workflow_id="$1"
  curl -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GITHUB_TOKEN}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/lawrenceslng/DevOps_Midterm_Infra/actions/workflows/${workflow_id}/dispatches" \
    -d '{"ref":"main"}'
}

# Function to terminate EC2 instance
terminate_instance() {
  aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
  aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
  aws configure set aws_session_token ${AWS_SESSION_TOKEN}
  # Get instance ID from metadata service
  # INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
  # Terminate the instance
  aws ec2 terminate-instances --instance-id ${INSTANCE_ID}
}

# Check if frontend is accessible
if curl -f http://localhost > /dev/null 2>&1; then
  echo "Frontend is accessible"
  # Check if backend is accessible and returns correct health message
  HEALTH_RESPONSE=$(curl -s http://localhost:3001/api/health)
  if [[ "$HEALTH_RESPONSE" == *"Health status OK!!"* ]]; then
    echo "Backend is accessible and healthy"
    # Trigger Deploy to QA workflow
    trigger_workflow "Deploy_To_QA.yaml"
    # Terminate the instance
    terminate_instance
    exit 0
  else
    echo "Backend health check failed: Unexpected response"
    echo "Got: $HEALTH_RESPONSE"
    # Trigger Delete from ECR workflow
    trigger_workflow "Delete_From_ECR.yaml"
    # Terminate the instance
    terminate_instance
    exit 1
  fi
else
  echo "Frontend is not accessible"
  # Trigger Delete from ECR workflow
  trigger_workflow "Delete_From_ECR.yaml"
  # Terminate the instance
  terminate_instance
  exit 1
fi
