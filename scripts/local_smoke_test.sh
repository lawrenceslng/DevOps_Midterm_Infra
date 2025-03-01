#!/bin/bash

# GitHub and Repository Configuration
GITHUB_TOKEN=$(cat github_token.txt)

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
  # Get instance ID from metadata service
  INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
  # Terminate the instance
  aws ec2 terminate-instances --instance-id "${INSTANCE_ID}"
}

# Check if frontend is accessible
if curl -f http://localhost > /dev/null 2>&1; then
  echo "Frontend is accessible"
  # Check if backend is accessible and returns correct health message
  HEALTH_RESPONSE=$(curl -s http://localhost:3001/api/health)
  if [[ "$HEALTH_RESPONSE" == *"Health status OK!!"* ]]; then
    echo "Backend is accessible and healthy"
    # Trigger Deploy to QA workflow
    trigger_workflow "Deploy_To_QA"
    # Terminate the instance
    terminate_instance
    exit 0
  else
    echo "Backend health check failed: Unexpected response"
    echo "Got: $HEALTH_RESPONSE"
    # Trigger Delete from ECR workflow
    trigger_workflow "Delete_From_ECR"
    # Terminate the instance
    terminate_instance
    exit 1
  fi
else
  echo "Frontend is not accessible"
  # Trigger Delete from ECR workflow
  trigger_workflow "Delete_From_ECR"
  # Terminate the instance
  terminate_instance
  exit 1
fi
