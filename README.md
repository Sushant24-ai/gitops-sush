# GitOps-Based Deployment Pipeline on AWS EKS

This repository contains a fully automated GitOps-driven CI/CD pipeline that deploys a sample microservice application to an AWS EKS cluster.

## Architecture Overview

The architecture consists of:

1. **Infrastructure Layer**: AWS EKS cluster and associated resources provisioned with Terraform
2. **GitOps Layer**: ArgoCD for continuous deployment from Git repository
3. **Application Layer**: Sample microservice packaged with Helm

![Architecture Diagram]

## Components

### Infrastructure Provisioning

- AWS EKS cluster provisioned using Terraform
- VPC, subnets, security groups, and other networking components
- IAM roles and policies for secure EKS operation
- Additional Kubernetes tools installed via Helm

### GitOps Implementation

- ArgoCD watches the Git repository for changes
- When changes are detected in the deployment manifests, ArgoCD automatically syncs the cluster
- Rollback mechanisms are in place to recover from failed deployments

### Application Deployment

- Sample microservice containerized with Docker
- Helm chart for deployment to Kubernetes
- Health checks and readiness probes configured
- Automatic rollback for failed deployments

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed (v1.0.0+)
- kubectl installed
- Helm installed (v3.0.0+)
- Git client
- Docker installed (for building the sample microservice)

## Getting Started

### 1. Provisioning Infrastructure

```bash
# Clone the repository
git clone <repository-url>
cd <repository-directory>

# Initialize Terraform
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific configurations

# Apply Terraform configuration
terraform init
terraform plan
terraform apply
