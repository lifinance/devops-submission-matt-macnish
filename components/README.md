# Terraform Deployment for FalafelAPI Infrastructure

This repository contains Terraform configurations to set up a robust AWS infrastructure for the FalafelAPI. The architecture comprises:

- A VPC with both public and private subnets spanning across three availability zones.
- ECS Fargate for running the FalafelAPI server in a serverless manner.
- DynamoDB for storage.
- Elastic Container Registry (ECR) to store the FalafelAPI Docker images.
- Necessary gateways and security groups to ensure the infrastructure is secure and traffic flows appropriately.

## Infrastructure Overview

### Virtual Private Cloud (VPC)

- **VPC Name**: `falafel_vpc`
- **CIDR Block**: `10.1.0.0/24`

The VPC is partitioned into three public and three private subnets, each in a separate availability zone:

**Public Subnets (CIDR Blocks):**
- `10.1.0.192/28`
- `10.1.0.208/28`
- `10.1.0.224/28`

**Private Subnets (CIDR Blocks):**
- `10.1.0.0/26`
- `10.1.0.64/26`
- `10.1.0.128/26`

### NAT and Internet Gateways

Public subnets interface with the Internet Gateway (IGW) for external communication, while private subnets route outbound traffic via a Network Address Translation Gateway (NATGW) situated in the public subnets.

## Continuous Integration and Deployment with GitHub Actions

The infrastructure as code is not just about defining resources but ensuring that they are deployed correctly and securely. To this end, a comprehensive CI/CD pipeline using GitHub Actions is employed.

### Workflow

The `.github/workflows` directory contains a GitHub Actions workflow that:

1. **Validates** Terraform configurations using `terraform fmt`.
2. **Lints** the code with `tflint`.
3. **Checks** for security vulnerabilities with `tfsec`.
4. **Plans** the Terraform changes.
5. **Applies** the changes when code is merged into the main branch.

### Steps

1. **Terraform Format, Lint, and Security Checks**: On every push, the workflow checks out the code, sets up Terraform, AWS credentials, and performs format, lint, and security checks.
   
2. **Terraform Plan**: After the initial checks, Terraform initialization and planning steps are executed to provide a preview of the changes that will be applied.
   
3. **Terraform Apply**: On merges to the main branch, after successful planning, the changes are automatically applied, ensuring that the infrastructure always reflects the latest code.
