# Banking System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A microservices-based banking system with React frontend and Spring Boot backend services. This project demonstrates modern cloud-native architecture patterns with multiple deployment options.

**🚀 New to this project? Check out the [Quick Start Guide](QUICK_START.md) to get up and running in minutes!**

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
- Node.js (for webapp dependencies)

**Setup Steps:**
```bash
# 1. Clone and navigate to the project
cd banking-system

# 2. Install webapp dependencies locally (to avoid Docker timeout)
cd webapp
npm install --registry https://registry.npmmirror.com
cd ..

# 3. Build microservices (optional, for faster startup)
cd microservices
./build-all.sh
cd ..

# 4. Start all services
docker-compose up -d

# 5. Wait for services to start (30-60 seconds)
# Check status: docker-compose ps

# 6. Access the application
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

# Security-focused deployment
docker-compose -f docker-compose.security.yml up -d

# Build all microservices
cd microservices && ./build-all.sh
```

### 2. AWS ECS Deployment

**Prerequisites:**
- AWS CLI configured
- Terraform installed
- Docker installed
- Node.js (for webapp dependencies)

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
- Node.js (for webapp dependencies)

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

### Phone Number Validation
The system supports multiple phone number formats:
- International format: `+1234567890`
- Nigerian format: `08130262842`
- Standard format: `1234567890`

Validation pattern: `^(\\+?[1-9]\\d{1,14}|0\\d{10})$`

### Database
MySQL database configuration:
- Username: Set via environment variable `DB_USERNAME` (default: root)
- Password: Set via environment variable `DB_PASSWORD` (default: password)
- Database: `banking_system`
- Port: 3306

**Security Note**: Never use default credentials in production. Always use strong, unique passwords and consider using AWS Secrets Manager or Docker secrets for credential management. See [SECURITY.md](SECURITY.md) for detailed security guidelines.

### Environment Configuration
Copy `.env.template` to `.env` and update with your values:
```bash
cp .env.template .env
# Edit .env with your configuration
```

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
- **Important**: Install webapp dependencies locally first: `cd webapp && npm install`
- Wait for services to start up completely (30-60 seconds)
- If npm timeout occurs during build, use: `npm install --registry https://registry.npmmirror.com`
- Check service health: `docker-compose ps` and `docker-compose logs [service-name]`

**AWS Deployments:**
- Verify AWS credentials are configured: `aws sts get-caller-identity`
- Check AWS service limits and quotas
- Ensure proper IAM permissions for ECS/EKS
- **Important**: Node.js is required for webapp dependency installation during deployment
- Verify ECR repositories exist before pushing images

**EKS Specific:**
- Verify kubectl is configured correctly: `kubectl cluster-info`
- Check node group capacity and scaling
- Monitor pod status: `kubectl get pods -n banking-system`
- Check LoadBalancer services: `kubectl get svc -n banking-system`
- Verify RDS connectivity from EKS cluster

**Performance Issues:**
- Monitor resource usage: `docker stats`
- Check database connections and query performance
- Review application logs for bottlenecks
- Consider scaling services horizontally

**Security Issues:**
- Review [SECURITY.md](SECURITY.md) for security guidelines
- Ensure proper credential management
- Check network security groups and firewall rules
- Verify SSL/TLS configuration in production

## 📊 Monitoring and Health Checks

### Service Health Endpoints
- Service Discovery: http://localhost:8761
- Account Service: http://localhost:8081/actuator/health
- Transaction Service: http://localhost:8082/actuator/health
- Notification Service: http://localhost:8083/actuator/health
- Audit Service: http://localhost:8084/actuator/health
- API Gateway: http://localhost:8080/actuator/health

### Database Health
```bash
# Check MySQL connection
docker exec banking-mysql mysqladmin ping -h localhost -u root -ppassword
```

### Container Status
```bash
# Check all container status
docker-compose ps

# View resource usage
docker stats

# Check logs
docker-compose logs -f [service-name]
```

## 🔒 Security

This project includes comprehensive security guidelines. Please review [SECURITY.md](SECURITY.md) before deploying to production.

### Quick Security Checklist
- [ ] Change default database credentials
- [ ] Configure environment variables properly
- [ ] Use HTTPS in production
- [ ] Set up proper firewall rules
- [ ] Enable audit logging
- [ ] Regular security updates

## 📞 Support

If you encounter any issues or have questions:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Review [SECURITY.md](SECURITY.md) for security-related issues
3. Check existing issues in this repository
4. Open a new issue with detailed information

## 📈 Performance Optimization

### Local Development
- Pre-build microservices: `cd microservices && ./build-all.sh`
- Use Docker layer caching
- Allocate sufficient resources to Docker

### Production Deployment
- Use multi-stage Docker builds
- Implement horizontal pod autoscaling (EKS)
- Configure database connection pooling
- Set up CDN for static assets
- Enable application-level caching

---

**Happy Banking! 🏦**

For detailed deployment status and verification, see [DEPLOYMENT_STATUS.md](DEPLOYMENT_STATUS.md).