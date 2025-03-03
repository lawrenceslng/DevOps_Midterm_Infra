# DevOps Midterm Infrastructure Repository

This repository contains the infrastructure code, configuration scripts, and CI/CD workflows for the Single Page Application hosted at [DevOps_Midterm_SPA](https://github.com/lawrenceslng/DevOps_Midterm_SPA).

The Github Actions configured in this repository is reponsible for checking out the latest version of the Source code and deploying it to an AWS EC2 machine every night if the build is successful.

## Repository Structure

**Note**: There is a V1 and a V2 of the Github Action workflows and scripts. The difference is that V1 pushes the newly built image with both a timestamp and `latest` tag whereas V2 only pushes the newly built image with the timestamp. V2 is a better workflow because it guarantees that the image that is tagged as `latest` is always guaranteed to be a working build.

### Configurations
- `docker-compose.prod.yml` - Production environment Docker Compose configuration
- `docker-compose.temp.yml` - Temporary environment Docker Compose configuration
- `qa-ec2-nginx.conf` - Nginx configuration for QA EC2 instance
- `temp-ec2-nginx.conf` - Nginx configuration for temporary EC2 instance

### Scripts
- `build_and_push.sh` / `build_and_push_V2.sh` - Scripts for building and pushing Docker images
- `copy_to_temp_ec2.sh` / `copy_to_temp_ec2_V2.sh` - Scripts for deploying to temporary EC2 instances
- `local_smoke_test.sh` / `local_smoke_test_V2.sh` - Local smoke test scripts
- `setup_QA_EC2.sh` - QA environment EC2 setup script
- `setup_temp_ec2.sh` - Temporary environment EC2 setup script

### CI/CD Workflows
- Nightly Test Deployment
- QA Environment Deployment
- ECR Cleanup

## Purpose

This infrastructure repository is designed to support the deployment, testing, and maintenance of a React frontend and Node.js Express backend. It includes:

1. Docker containerization configurations for consistent environments
2. Nginx server configurations for proper routing and serving
3. Automated build and deployment scripts
4. Infrastructure setup scripts for AWS EC2 instances
5. Comprehensive CI/CD pipelines for testing and deployment
6. Local development and testing utilities

**Note**: There are 2 EC2 instances involved for this CI/CD process: 
1. Temporary EC2 - This is started and terminated automatically. This EC2 not only hosts the frontend static build and spins up the backend server, but it also spins up a Docker image of a MySQL DB to serve as the local database and an Nginx image to serve as the reverse proxy rather than using the installed Nginx on the EC2 itself.
2. QA EC2 - This is continuously running and serves up the website with the latest stable build. This machine only needs to spin up the backend server via Docker since the DB used is an RDS instance and the Nginx that is installed on the EC2 itself is used.

The different approaches used for the Nginx server is just an exercise in trying both approaches. I do not yet know the best practices for dealing with a reverse proxy and look forward to learning about it more!

## License

This project is licensed under the terms included in the LICENSE file.