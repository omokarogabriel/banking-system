#!/bin/bash
set -euo pipefail

echo "Building all microservices..."

# Array of services to build
services=("service-discovery" "account-service" "transaction-service" "notification-service" "audit-service" "api-gateway")

# Build each service
for service in "${services[@]}"; do
    echo "Building $service..."
    if [ -d "$service" ]; then
        cd "$service"
        if [ -f "pom.xml" ]; then
            mvn clean package -DskipTests
            echo "✅ $service built successfully"
        else
            echo "⚠️  No pom.xml found in $service"
        fi
        cd ..
    else
        echo "❌ Directory $service not found"
    fi
done

echo "All microservices build completed!"