# FalafelAPI Infrastructure and Application Deployment Guide

This repository contains both the Terraform configurations required to set up the FalafelAPI's AWS infrastructure and the Docker containerization process of the application for Elastic Container Registry (ECR) deployment.

## Deployment Sequence

For a fresh deployment, the following sequence is essential due to the interdependence between the infrastructure and the application:

### 1. **Terraform Infrastructure Setup**

Initially, kick off the Terraform pipeline. When setting up for the first time, this is expected to fail because of a circular dependency. The Terraform setup expects a container image in the ECR repository, but at this point, the ECR repository isn't ready yet.

Errors with ALB deployment are expected due to it not fully waiting for subnet creation, even with depends_on

### 2. **Application Deployment to ECR**

Once the initial Terraform pipeline run completes, initiate the application's GitHub Action. This action will build the Docker image of the application and push it to the newly created ECR repository.

### 3. **Finalizing Infrastructure Setup**

After the Docker image of the application is available in the ECR, rerun the Terraform pipeline. This time, Terraform will complete the setup, deploying the ECS tasks using the Docker image from ECR and finalizing the rest of the infrastructure.

## Quick Links

- [Terraform Infrastructure Setup Guide](components\README.md)
- [Application Dockerization and ECR Deployment Guide](application\README.md)

## Future Plans:

1. **Separate Deployment of Backend Infrastructure**: To create a more streamlined deployment process, plans are in place to separate the deployment of backend infrastructure from the container infrastructure. This change aims to avoid the initial errors stemming from circular dependencies.

2. **Implement Prometheus Logging**: Finalize the integration of Prometheus for logging. This will enhance monitoring capabilities, providing granular insights into system performance and potential issues.

3. **Infrastructure as Code Enhancements**: Explore potential optimizations in Terraform configurations to make the infrastructure setup more modular and manageable.

4. **Container Orchestration**: Look into enhancing the ECS setup for better scalability and fault tolerance, possibly integrating with other AWS services or Kubernetes.

5. **Security Improvements**: Constantly review and update the security configurations, ensuring that the infrastructure and application are resistant to potential threats.

Feel free to provide feedback or suggest additional improvements to enhance the deployment process and the overall robustness of the FalafelAPI's setup.

## Required Github Actions Secrets
the following GHA secrets are required to run the deployments

AWS_ACCESS_KEY
AWS_SECRET_ACCESS_KEY
AWS_REGION
ECR_REPOSITORY