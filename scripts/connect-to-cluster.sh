#!/bin/bash

# Connect to EKS Cluster Script
# This script configures kubectl to connect to the EKS cluster

set -e

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed or not in PATH"
    exit 1
fi

# Check if Terraform output is available
if [ ! -d "../terraform" ]; then
    echo "Error: Cannot find Terraform directory"
    exit 1
fi

# Change to Terraform directory
cd ../terraform

# Get cluster name and region from Terraform output
echo "Getting cluster information from Terraform output..."
if ! command -v terraform &> /dev/null; then
    echo "Error: Terraform is not installed or not in PATH"
    exit 1
fi

CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw region)

if [ -z "$CLUSTER_NAME" ] || [ -z "$REGION" ]; then
    echo "Error: Could not retrieve cluster information from Terraform output"
    exit 1
fi

echo "Cluster name: $CLUSTER_NAME"
echo "Region: $REGION"

# Update kubeconfig for the EKS cluster
echo "Updating kubeconfig for the EKS cluster..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# Verify connection to the cluster
echo "Verifying connection to the cluster..."
if kubectl get nodes; then
    echo "Successfully connected to the EKS cluster!"
else
    echo "Error: Failed to connect to the EKS cluster"
    exit 1
fi

# Display useful information
NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)
echo "Cluster has $NODE_COUNT nodes"

echo "Cluster add-ons:"
kubectl get deployments -n kube-system

# Return to the original directory
cd - > /dev/null

echo "Connection to EKS cluster $CLUSTER_NAME established successfully!"
