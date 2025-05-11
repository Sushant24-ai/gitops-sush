# GitOps-Based Deployment Pipeline on AWS EKS

This repository contains a fully automated GitOps-driven CI/CD pipeline that deploys a sample microservice application to an AWS EKS cluster.

## Architecture Overview

The architecture consists of:

1. **Infrastructure Layer**: AWS EKS cluster and associated resources provisioned with Terraform
2. **GitOps Layer**: ArgoCD for continuous deployment from Git repository
3. **Application Layer**: Sample microservice packaged with Helm

The architecture follows GitOps principles:
- Git as the single source of truth
- Declarative descriptions of infrastructure and applications
- Automated synchronization of Git state to cluster state
- Automatic rollbacks for failed deployments

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
git clone https://github.com/Sushant24-ai/gitops-sush.git
cd gitops-sush

# Initialize Terraform
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific configurations

# Apply Terraform configuration
terraform init
terraform plan
terraform apply
```

### 2. Setting up ArgoCD

After the EKS cluster is provisioned, you need to connect to it and set up ArgoCD:

```bash
# Connect to the EKS cluster
./scripts/connect-to-cluster.sh

# Install and configure ArgoCD
./scripts/setup-argocd.sh
```

This will install ArgoCD on your EKS cluster and configure it to watch the Git repository for changes in the Helm charts.

### 3. Deploying the Sample Microservice

The sample microservice will be automatically deployed by ArgoCD once it's installed. You can verify the deployment:

```bash
# Check the ArgoCD application status
kubectl get applications -n argocd

# Check the deployed microservice
kubectl get pods -n sample-app
```

### 4. Testing Automatic Rollbacks

To test the automatic rollback functionality:

```bash
# Run the rollback test script
./tests/rollback-test.sh
```

This script will deploy a broken version of the microservice that fails health checks, triggering an automatic rollback.

## Design Choices

### Infrastructure as Code with Terraform

We chose Terraform for infrastructure provisioning because:
- It provides a declarative way to define AWS resources
- It has excellent support for AWS EKS
- It enables version-controlled infrastructure changes

### GitOps with ArgoCD

ArgoCD was selected as the GitOps tool because:
- It provides automatic synchronization between Git and the cluster
- It supports Helm charts natively
- It has built-in support for rollbacks and health checks

### Containerization and Helm

The sample microservice is containerized with Docker and deployed with Helm:
- Containerization ensures consistent environments
- Helm provides templating for Kubernetes manifests
- Helm supports versioning and rollbacks

## Repository Structure

- `/terraform` - Terraform configurations for AWS EKS
- `/kubernetes/argocd` - ArgoCD installation and configuration
- `/helm-charts` - Helm charts for the sample microservice
- `/sample-microservice` - Source code for the sample application
- `/scripts` - Utility scripts for setting up the environment
- `/tests` - Test scripts for validating functionality
