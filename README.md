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

- [Terraform Infrastructure Setup Guide](https://github.com/Pretendfriend/Falafel-API-Server/blob/a005238977a6bb14f39a9830e3c883c1996b0be4/components/README.md)
- [Application Dockerization and ECR Deployment Guide](https://github.com/Pretendfriend/Falafel-API-Server/blob/a005238977a6bb14f39a9830e3c883c1996b0be4/application/README.md)

## Future Plans:

1. **Separate Deployment of Backend Infrastructure**: To create a more streamlined deployment process, plans are in place to separate the deployment of backend infrastructure from the container infrastructure. This change aims to avoid the initial errors stemming from circular dependencies.

2. **Implement Prometheus Logging**: Finalize the integration of Prometheus for logging. This will enhance monitoring capabilities, providing granular insights into system performance and potential issues.

3. **Infrastructure as Code Enhancements**: Explore potential optimizations in Terraform configurations to make the infrastructure setup more modular and manageable.

4. **Container Orchestration**: Look into enhancing the ECS setup for better scalability and fault tolerance, possibly integrating with other AWS services or Kubernetes.

5. **Security Improvements**: Constantly review and update the security configurations, ensuring that the infrastructure and application are resistant to potential threats.

Feel free to provide feedback or suggest additional improvements to enhance the deployment process and the overall robustness of the FalafelAPI's setup.

## Required Github Actions Secrets
the following GHA secrets are required to run the deployments

AWS_ACCESS_KEY\
AWS_SECRET_ACCESS_KEY\
AWS_REGION\
ECR_REPOSITORY

## Design decisions

### Database Choice
The requirements stated that the input would be JSON, so with that information I decided to use DynamoDB in AWS as it is scalable and can deal with a significant amount of read writes.  The solution is also fully managed.

The drawback to this decsion is that a local setup is significantly more difficult, however this could be rectified by setting up a dev instance of DynamoDB in a lower enviroment for developers to connect to.

### ECS over EKS
ECS was chosen due to the requirements only specifying a single application.  Ths meant there was no need for a full microservices architecture. ECS offers a great option for more isolated workloads utilising containers, this can have full applications with several microservices as well.  However it is not as managable and customisable to you needs as EKS would be.  Finally Fargate was chosen as only running one service does not require a Cluster of EC2 setup.  Fargates host infrastructure is fully managed by AWS which reduces the opertional burden of the administators.

## Final Thoughts

It was an enjoyable excercise and I have learned a an amount about Javascript, however the task whilt appearing simple at first is larger once you pull apart all the required elements

### What went well
I was able to use my knowledge of using other languages like Python to adapt to using Javascript and whilst there were times I was frustrated and wanted to just use the language I knew, I am glad I didn't. \
The initial design of the AWS infrastructure and code was straight forward.

### What didn't go well
I underestimated the size of the task initially, and when planning I realised the true scope. My lack of understanding of NodeJS and Javascript led me down a few rabbit holes which became quite frustrating. I had changed the testing framework several times trying to get one that worked, and I really had issues with my first choice of Mocha and Chai as it seemed be doing a lot more than required.  After changing to Jest I found it easier to complete the works.  I had struggled to get the mocking of GET from the mock DynamoDB and ended up deciding to scrap that section to focus on the ore task.\
I started the work to implement monitoring with Prometheus and Grafana but ran out of time.

###  How I would change it
If this was my choice to deploy I would not use a Javascript API and use AWS API gateway instead.  I believe this would be a more stable and scalable design. I would also ensure a WAF was protecting the edge as well DDOS protection.

### Comments on the task
I think the task is quite a large ask and it was difficult to fit in around personal commitments and working full time.  The feedback I would give is shorten the task by providing the initial setup of the VPC and Subnets in a repo that the person can just fork and go from there.  Further to that suggestion I would sneak in a few gotchas, like subnets all going to one AZ or some bad NACL or Routing design.