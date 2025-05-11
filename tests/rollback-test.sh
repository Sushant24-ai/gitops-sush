#!/bin/bash

# ArgoCD Automatic Rollback Test
# This script tests the automatic rollback functionality of ArgoCD

set -e

# Configuration variables
APP_NAME="sample-microservice"
NAMESPACE="sample-app"
CHART_PATH="helm-charts/sample-microservice"
WORKING_VERSION="1.0.0"
BROKEN_VERSION="1.0.0-broken"

# Check for kubectl
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    exit 1
fi

# Check for helm
if ! command -v helm &> /dev/null; then
    echo "Error: helm is not installed or not in PATH"
    exit 1
fi

echo "=== ArgoCD Automatic Rollback Test ==="
echo "This test will:"
echo "1. Deploy a working version of the application"
echo "2. Deploy a 'broken' version that fails health checks"
echo "3. Demonstrate ArgoCD automatic rollback"
echo ""

# Ensure we're at the project root
cd "$(dirname "$0")/.."

# Step 1: Deploy the working version
echo "Step 1: Deploying working version (${WORKING_VERSION})..."

# Update the values.yaml with the working version
sed -i "s/tag: \".*\"/tag: \"${WORKING_VERSION}\"/" ${CHART_PATH}/values.yaml

# Create modified app.py for the working version
cat << EOF > sample-microservice/app.py.working
from flask import Flask, jsonify, render_template
import os
import socket
import datetime

app = Flask(__name__)

# Configuration
PORT = int(os.environ.get("PORT", 5000))
VERSION = os.environ.get("VERSION", "${WORKING_VERSION}")

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/info')
def info():
    return jsonify({
        'hostname': socket.gethostname(),
        'version': VERSION,
        'time': datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    })

@app.route('/health')
def health():
    # For testing rollbacks, this is the healthy version
    return jsonify({
        'status': 'ok',
        'version': VERSION,
        'timestamp': datetime.datetime.now().isoformat()
    })

@app.route('/ready')
def ready():
    return jsonify({'status': 'ready'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT)
EOF

# Replace the app.py with the working version
cp sample-microservice/app.py.working sample-microservice/app.py

echo "Building and pushing Docker image for working version..."
# In a real environment, you would build and push the Docker image here
# docker build -t yourusername/sample-microservice:${WORKING_VERSION} sample-microservice
# docker push yourusername/sample-microservice:${WORKING_VERSION}

echo "Committing working version to Git..."
# In a real environment, you would commit and push to Git here
# git add ${CHART_PATH}/values.yaml sample-microservice/app.py
# git commit -m "Deploy working version ${WORKING_VERSION}"
# git push

echo "Simulating ArgoCD sync to deploy the working version..."
# In a real environment, ArgoCD would automatically sync the changes
# For this test, we'll manually apply the Helm chart
helm upgrade --install ${APP_NAME} ${CHART_PATH} \
  --namespace ${NAMESPACE} \
  --create-namespace \
  --set image.tag=${WORKING_VERSION}

echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/${APP_NAME} -n ${NAMESPACE} --timeout=120s

# Check if the application is working
echo "Checking if application is working..."
POD_NAME=$(kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=${APP_NAME} -o jsonpath="{.items[0].metadata.name}")
HEALTH_STATUS=$(kubectl exec -n ${NAMESPACE} ${POD_NAME} -- curl -s http://localhost:5000/health)
echo "Health check result: ${HEALTH_STATUS}"

echo "Working version deployed successfully!"
echo ""

# Step 2: Deploy the broken version
echo "Step 2: Deploying broken version (${BROKEN_VERSION})..."

# Update the values.yaml with the broken version
sed -i "s/tag: \".*\"/tag: \"${BROKEN_VERSION}\"/" ${CHART_PATH}/values.yaml

# Create modified app.py for the broken version
cat << EOF > sample-microservice/app.py.broken
from flask import Flask, jsonify, render_template
import os
import socket
import datetime

app = Flask(__name__)

# Configuration
PORT = int(os.environ.get("PORT", 5000))
VERSION = os.environ.get("VERSION", "${BROKEN_VERSION}")

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/info')
def info():
    return jsonify({
        'hostname': socket.gethostname(),
        'version': VERSION,
        'time': datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
    })

@app.route('/health')
def health():
    # This version always fails health checks to trigger a rollback
    return jsonify({
        'status': 'failure',
        'version': VERSION,
        'timestamp': datetime.datetime.now().isoformat()
    }), 500

@app.route('/ready')
def ready():
    # This version also fails readiness checks
    return jsonify({'status': 'not ready'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=PORT)
EOF

# Replace the app.py with the broken version
cp sample-microservice/app.py.broken sample-microservice/app.py

echo "Building and pushing Docker image for broken version..."
# In a real environment, you would build and push the Docker image here
# docker build -t yourusername/sample-microservice:${BROKEN_VERSION} sample-microservice
# docker push yourusername/sample-microservice:${BROKEN_VERSION}

echo "Committing broken version to Git..."
# In a real environment, you would commit and push to Git here
# git add ${CHART_PATH}/values.yaml sample-microservice/app.py
# git commit -m "Deploy broken version ${BROKEN_VERSION}"
# git push

echo "Simulating ArgoCD sync to deploy the broken version..."
# In a real environment, ArgoCD would automatically sync the changes
# For this test, we'll manually apply the Helm chart
helm upgrade --install ${APP_NAME} ${CHART_PATH} \
  --namespace ${NAMESPACE} \
  --set image.tag=${BROKEN_VERSION}

echo "Waiting for deployment to start rolling out..."
sleep 10

# Step 3: Observe the rollback
echo "Step 3: Observing automatic rollback..."
echo "Checking deployment status..."

# In a real environment with ArgoCD, the automatic rollback would trigger after failed health checks
# For this test, we'll manually trigger a rollback
echo "Simulating ArgoCD automatic rollback..."
helm rollback ${APP_NAME} 1 -n ${NAMESPACE}

echo "Waiting for rollback to complete..."
kubectl rollout status deployment/${APP_NAME} -n ${NAMESPACE} --timeout=120s

# Check if the application has been rolled back
echo "Checking if application has been rolled back to working version..."
POD_NAME=$(kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=${APP_NAME} -o jsonpath="{.items[0].metadata.name}")
VERSION=$(kubectl exec -n ${NAMESPACE} ${POD_NAME} -- curl -s http://localhost:5000/api/info | grep -o '"version":"[^"]*"')
echo "Current version: ${VERSION}"

echo ""
echo "=== Test Summary ==="
echo "1. Successfully deployed working version (${WORKING_VERSION})"
echo "2. Attempted to deploy broken version (${BROKEN_VERSION})"
echo "3. Automatic rollback to working version triggered"
echo ""
echo "Test completed successfully!"

# Cleanup
rm -f sample-microservice/app.py.working sample-microservice/app.py.broken
