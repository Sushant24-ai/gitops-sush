#!/bin/bash

# ArgoCD Installation Script
# This script installs ArgoCD on the EKS cluster and sets up the initial configuration

set -e

# Check if kubectl is installed and configured
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    exit 1
fi

# Check if kubectl can access the cluster
if ! kubectl get nodes &> /dev/null; then
    echo "Error: kubectl cannot access the cluster. Please run connect-to-cluster.sh first"
    exit 1
fi

# Create namespace for ArgoCD
echo "Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl apply -n argocd -f ../kubernetes/argocd/install.yaml

# Wait for ArgoCD server to be ready
echo "Waiting for ArgoCD server to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get the ArgoCD admin password
echo "Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "ArgoCD admin password: $ARGOCD_PASSWORD"

# Expose ArgoCD server (for demo purposes, not recommended for production)
echo "Exposing ArgoCD server with LoadBalancer..."
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Wait for LoadBalancer to get an external IP
echo "Waiting for LoadBalancer external IP..."
EXTERNAL_IP=""
while [ -z "$EXTERNAL_IP" ]; do
    EXTERNAL_IP=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    if [ -z "$EXTERNAL_IP" ]; then
        EXTERNAL_IP=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    fi
    if [ -z "$EXTERNAL_IP" ]; then
        echo "Waiting for external IP..."
        sleep 10
    fi
done

echo "ArgoCD server is available at: https://$EXTERNAL_IP"
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"

# Install ArgoCD CLI (optional)
read -p "Do you want to install the ArgoCD CLI? (y/n) " INSTALL_CLI
if [[ "$INSTALL_CLI" =~ ^[Yy]$ ]]; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
        echo "Installing ArgoCD CLI on Linux..."
        curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
        sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
        rm argocd-linux-amd64
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        echo "Installing ArgoCD CLI on macOS..."
        brew install argocd
    else
        echo "Unsupported OS for automatic installation. Please install ArgoCD CLI manually from https://argo-cd.readthedocs.io/en/stable/cli_installation/"
    fi
fi

# Apply the ArgoCD application manifests
echo "Applying ArgoCD application manifests..."
kubectl apply -f ../kubernetes/argocd/project.yaml
kubectl apply -f ../kubernetes/argocd/repository.yaml
kubectl apply -f ../kubernetes/argocd/application.yaml

echo "ArgoCD setup completed!"
echo "To log in to ArgoCD CLI: argocd login $EXTERNAL_IP --username admin --password $ARGOCD_PASSWORD --insecure"
echo "Access the UI at: https://$EXTERNAL_IP"
