#!/bin/bash

# Check if frontend is accessible
if curl -f http://localhost > /dev/null 2>&1; then
  echo "Frontend is accessible"
  # Check if backend is accessible
  if curl -f http://localhost:3001/health > /dev/null 2>&1; then
    echo "Backend is accessible"
    exit 0
  else
    echo "Backend health check failed"
    exit 1
  fi
else
  echo "Frontend is not accessible"
  exit 1
fi
