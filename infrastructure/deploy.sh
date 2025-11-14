#!/bin/bash

# Build and push Docker images to ECR
echo "Building and pushing Docker images..."

# Get AWS account ID and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)

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

# Update ECS services
echo "Updating ECS services..."
aws ecs update-service --cluster banking-cluster --service service-discovery --force-new-deployment
aws ecs update-service --cluster banking-cluster --service account-service --force-new-deployment
aws ecs update-service --cluster banking-cluster --service api-gateway --force-new-deployment
aws ecs update-service --cluster banking-cluster --service webapp --force-new-deployment

echo "Deployment complete!"