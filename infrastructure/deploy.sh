#!/bin/bash
set -euo pipefail

# Build and push Docker images to ECR
echo "Building and pushing Docker images..."

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

# Update ECS services
echo "Updating ECS services..."
services_to_update=("service-discovery" "account-service" "transaction-service" "notification-service" "audit-service" "api-gateway" "webapp")

for service in "${services_to_update[@]}"; do
    echo "Updating ECS service: $service"
    if ! aws ecs update-service --cluster banking-cluster --service "$service" --force-new-deployment > /dev/null; then
        echo "Warning: Failed to update ECS service $service" >&2
    fi
done

echo "Deployment complete!"