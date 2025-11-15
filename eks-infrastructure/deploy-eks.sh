#!/bin/bash
set -euo pipefail

# Get AWS account ID and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [[ -z "$AWS_ACCOUNT_ID" ]]; then
    echo "Error: Failed to get AWS account ID" >&2
    exit 1
fi

AWS_REGION=$(aws configure get region)
if [[ -z "$AWS_REGION" ]]; then
    echo "Error: AWS region not configured" >&2
    exit 1
fi

echo "Building and pushing Docker images to ECR..."

# Login to ECR
echo "Logging into ECR..."
if ! aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"; then
    echo "Error: Failed to login to ECR" >&2
    exit 1
fi

# Build and push each service
services=("service-discovery" "account-service" "transaction-service" "notification-service" "audit-service" "api-gateway")

for service in "${services[@]}"; do
    echo "Building $service..."
    if ! docker build -t "banking/$service" "../microservices/$service/"; then
        echo "Error: Failed to build $service" >&2
        exit 1
    fi
    
    if ! docker tag "banking/$service:latest" "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/banking/$service:latest"; then
        echo "Error: Failed to tag $service" >&2
        exit 1
    fi
    
    if ! docker push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/banking/$service:latest"; then
        echo "Error: Failed to push $service" >&2
        exit 1
    fi
done

# Build and push webapp
echo "Building webapp..."
echo "Installing webapp dependencies..."
if [ ! -d "../webapp/node_modules" ]; then
    if ! (cd ../webapp && npm install --registry https://registry.npmmirror.com); then
        echo "Error: Failed to install webapp dependencies" >&2
        exit 1
    fi
else
    echo "Dependencies already installed, skipping..."
fi

if ! docker build -t "banking/webapp" "../webapp/"; then
    echo "Error: Failed to build webapp" >&2
    exit 1
fi

if ! docker tag "banking/webapp:latest" "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/banking/webapp:latest"; then
    echo "Error: Failed to tag webapp" >&2
    exit 1
fi

if ! docker push "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/banking/webapp:latest"; then
    echo "Error: Failed to push webapp" >&2
    exit 1
fi

echo "All images pushed successfully!"

# Update kubeconfig
echo "Updating kubeconfig..."
if ! aws eks update-kubeconfig --region "$AWS_REGION" --name banking-cluster; then
    echo "Error: Failed to update kubeconfig" >&2
    exit 1
fi

# Get RDS endpoint
echo "Getting RDS endpoint..."
RDS_ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier banking-mysql --query 'DBInstances[0].Endpoint.Address' --output text)
if [[ -z "$RDS_ENDPOINT" || "$RDS_ENDPOINT" == "None" ]]; then
    echo "Error: Failed to get RDS endpoint" >&2
    exit 1
fi

# Update Kubernetes manifests with actual values
echo "Updating Kubernetes manifests..."
if ! find k8s-manifests/ -name "*.yaml" -exec sed -i "s/<ECR_ACCOUNT_ID>/$AWS_ACCOUNT_ID/g" {} \;; then
    echo "Error: Failed to update ECR account ID in manifests" >&2
    exit 1
fi

if ! find k8s-manifests/ -name "*.yaml" -exec sed -i "s/<AWS_REGION>/$AWS_REGION/g" {} \;; then
    echo "Error: Failed to update AWS region in manifests" >&2
    exit 1
fi

if ! find k8s-manifests/ -name "*.yaml" -exec sed -i "s/<RDS_ENDPOINT>/$RDS_ENDPOINT/g" {} \;; then
    echo "Error: Failed to update RDS endpoint in manifests" >&2
    exit 1
fi

# Deploy to Kubernetes
echo "Deploying to Kubernetes..."
if ! kubectl apply -f k8s-manifests/namespace.yaml; then
    echo "Error: Failed to create namespace" >&2
    exit 1
fi

if ! kubectl apply -f k8s-manifests/service-discovery.yaml; then
    echo "Error: Failed to deploy service-discovery" >&2
    exit 1
fi

echo "Waiting for service-discovery to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/service-discovery -n banking-system

if ! kubectl apply -f k8s-manifests/account-service.yaml; then
    echo "Error: Failed to deploy account-service" >&2
    exit 1
fi

if ! kubectl apply -f k8s-manifests/transaction-service.yaml; then
    echo "Error: Failed to deploy transaction-service" >&2
    exit 1
fi

if ! kubectl apply -f k8s-manifests/notification-service.yaml; then
    echo "Error: Failed to deploy notification-service" >&2
    exit 1
fi

if ! kubectl apply -f k8s-manifests/audit-service.yaml; then
    echo "Error: Failed to deploy audit-service" >&2
    exit 1
fi

echo "Waiting for services to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/account-service -n banking-system
kubectl wait --for=condition=available --timeout=300s deployment/transaction-service -n banking-system
kubectl wait --for=condition=available --timeout=300s deployment/notification-service -n banking-system
kubectl wait --for=condition=available --timeout=300s deployment/audit-service -n banking-system

if ! kubectl apply -f k8s-manifests/api-gateway.yaml; then
    echo "Error: Failed to deploy api-gateway" >&2
    exit 1
fi

if ! kubectl apply -f k8s-manifests/webapp.yaml; then
    echo "Error: Failed to deploy webapp" >&2
    exit 1
fi

# Get LoadBalancer URLs
echo "Waiting for LoadBalancers to be ready..."
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' --timeout=600s service/api-gateway -n banking-system
kubectl wait --for=jsonpath='{.status.loadBalancer.ingress}' --timeout=600s service/webapp -n banking-system

API_GATEWAY_URL=$(kubectl get service api-gateway -n banking-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
WEBAPP_URL=$(kubectl get service webapp -n banking-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [[ -z "$API_GATEWAY_URL" ]]; then
    echo "Warning: API Gateway LoadBalancer URL not available" >&2
fi

if [[ -z "$WEBAPP_URL" ]]; then
    echo "Warning: WebApp LoadBalancer URL not available" >&2
fi

# Update webapp with API Gateway URL if available
if [[ -n "$API_GATEWAY_URL" ]]; then
    sed -i "s/<API_GATEWAY_LB_URL>/$API_GATEWAY_URL/g" k8s-manifests/webapp.yaml
    kubectl apply -f k8s-manifests/webapp.yaml
fi

echo "Deployment complete!"
echo "API Gateway: http://$API_GATEWAY_URL"
echo "Web App: http://$WEBAPP_URL"