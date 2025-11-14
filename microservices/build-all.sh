#!/bin/bash

echo "Building all microservices..."

# Build each service
cd service-discovery && mvn clean package -DskipTests && cd ..
cd account-service && mvn clean package -DskipTests && cd ..
cd transaction-service && mvn clean package -DskipTests && cd ..
cd notification-service && mvn clean package -DskipTests && cd ..
cd audit-service && mvn clean package -DskipTests && cd ..
cd api-gateway && mvn clean package -DskipTests && cd ..

echo "All services built successfully!"
echo "Run 'docker-compose up --build' to start the system"