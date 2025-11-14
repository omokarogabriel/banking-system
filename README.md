# Banking System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A microservices-based banking system with React frontend and Spring Boot backend services. This project demonstrates modern cloud-native architecture patterns with multiple deployment options.

## 🏗️ Architecture

### Backend Services
- **MySQL Database** - Data persistence
- **Service Discovery** - Eureka server for service registration
- **Account Service** - Account management
- **Transaction Service** - Transaction processing
- **Notification Service** - Notifications
- **Audit Service** - Audit logging
- **API Gateway** - Single entry point for all requests

### Frontend
- **React Web App** - User interface

## 🚀 Deployment Options

### 1. Local Development (Docker Compose)

**Prerequisites:**
- Docker
- Docker Compose

**Quick Start:**
```bash
# Clone and navigate to the project
cd banking-system

# Start the entire application
docker-compose up -d

# Access the application
# Frontend: http://localhost:3000
# API Gateway: http://localhost:8080
# Service Discovery: http://localhost:8761
```

**Commands:**
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Rebuild and restart
docker-compose up -d --build

# Backend only
cd microservices && docker-compose up -d
```

### 2. AWS ECS Deployment

**Prerequisites:**
- AWS CLI configured
- Terraform installed
- Docker installed

**Deploy to ECS:**
```bash
cd infrastructure
terraform init
terraform apply
./deploy.sh
```

**Features:**
- ECS Fargate for serverless containers
- Application Load Balancer
- RDS MySQL database
- ECR for container registry
- CloudWatch logging

### 3. AWS EKS Deployment

**Prerequisites:**
- AWS CLI configured
- Terraform installed
- kubectl installed
- Docker installed

**Deploy to EKS:**
```bash
cd eks-infrastructure
terraform init
terraform apply
./deploy-eks.sh
```

**Features:**
- Managed Kubernetes service
- Auto-scaling node groups
- LoadBalancer services
- High availability across AZs
- Kubernetes-native scaling and management

## 📊 Service Ports

| Service | Port |
|---------|------|
| Frontend | 3000 |
| API Gateway | 8080 |
| Account Service | 8081 |
| Transaction Service | 8082 |
| Notification Service | 8083 |
| Audit Service | 8084 |
| Service Discovery | 8761 |
| MySQL | 3306 |

## 🛠️ Development

### Backend
Each microservice is a Spring Boot application located in the `microservices/` directory.

### Frontend
React application located in the `webapp/` directory.

### Database
MySQL database with default credentials:
- Username: `root`
- Password: `password`
- Database: `banking_system`

## 📁 Project Structure

```
banking-system/
├── microservices/
│   ├── service-discovery/
│   ├── account-service/
│   ├── transaction-service/
│   ├── notification-service/
│   ├── audit-service/
│   ├── api-gateway/
│   └── docker-compose.yml
├── webapp/
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── Dockerfile
├── infrastructure/          # ECS deployment
│   ├── main.tf
│   ├── ecs.tf
│   ├── rds.tf
│   ├── alb.tf
│   └── deploy.sh
├── eks-infrastructure/      # EKS deployment
│   ├── main.tf
│   ├── eks.tf
│   ├── k8s-manifests/
│   └── deploy-eks.sh
├── docker-compose.yml       # Full stack
├── LICENSE
└── README.md
```

## 🤝 Contributing

We welcome contributions! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔧 Troubleshooting

### Common Issues

**Docker Compose:**
- Ensure Docker is running
- Check port conflicts (3000, 8080, 8761, 3306)
- Wait for services to start up completely

**AWS Deployments:**
- Verify AWS credentials are configured
- Check AWS service limits
- Ensure proper IAM permissions

**EKS Specific:**
- Verify kubectl is configured correctly
- Check node group capacity
- Monitor pod status with `kubectl get pods -n banking-system`

## 📞 Support

If you encounter any issues or have questions, please open an issue in this repository.

---

**Happy Banking! 🏦**