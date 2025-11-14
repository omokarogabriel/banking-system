#!/bin/bash

# Get AWS account ID and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)

echo "Building and pushing Docker images to ECR..."

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build and push each service
services=("service-discovery" "account-service" "transaction-service" "notification-service" "audit-service" "api-gateway")

for service in "${services[@]}"; do
    echo "Building $service..."
    docker build -t banking/$service ../microservices/$service/
    docker tag banking/$service:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/banking/$service:latest
    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/banking/$service:latest
done

# Build and push webapp
echo "Building webapp..."
docker build -t banking/webapp ../webapp/
docker tag banking/webapp:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/banking/webapp:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/banking/webapp:latest

echo "All images pushed successfully!"

# Update kubeconfig
echo "Updating kubeconfig..."
aws eks update-kubeconfig --region $AWS_REGION --name banking-cluster

# Get RDS endpoint
RDS_ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier banking-mysql --query 'DBInstances[0].Endpoint.Address' --output text)

# Update Kubernetes manifests with actual values
echo "Updating Kubernetes manifests..."
find k8s-manifests/ -name "*.yaml" -exec sed -i "s/<ECR_ACCOUNT_ID>/$AWS_ACCOUNT_ID/g" {} \;
find k8s-manifests/ -name "*.yaml" -exec sed -i "s/<AWS_REGION>/$AWS_REGION/g" {} \;
find k8s-manifests/ -name "*.yaml" -exec sed -i "s/<RDS_ENDPOINT>/$RDS_ENDPOINT/g" {} \;

# Deploy to Kubernetes
echo "Deploying to Kubernetes..."
kubectl apply -f k8s-manifests/namespace.yaml
kubectl apply -f k8s-manifests/service-discovery.yaml
sleep 30
kubectl apply -f k8s-manifests/account-service.yaml
sleep 30
kubectl apply -f k8s-manifests/api-gateway.yaml
kubectl apply -f k8s-manifests/webapp.yaml

# Get LoadBalancer URLs
echo "Waiting for LoadBalancers to be ready..."
sleep 60

API_GATEWAY_URL=$(kubectl get service api-gateway -n banking-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
WEBAPP_URL=$(kubectl get service webapp -n banking-system -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Update webapp with API Gateway URL
sed -i "s/<API_GATEWAY_LB_URL>/$API_GATEWAY_URL/g" k8s-manifests/webapp.yaml
kubectl apply -f k8s-manifests/webapp.yaml

echo "Deployment complete!"
echo "API Gateway: http://$API_GATEWAY_URL"
echo "Web App: http://$WEBAPP_URL"