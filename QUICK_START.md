# Banking System - Quick Start Guide

Get your banking system up and running in minutes!

---

## 🚀 Option 1: Local Development (Fastest)

### Prerequisites
- Docker and Docker Compose installed
- 8GB+ RAM available
- Ports 3000, 8080-8084, 8761, 3306 available

### Steps

```bash
# 1. Clone the repository
cd banking-system

# 2. Install webapp dependencies (prevents timeout)
cd webapp
npm install --registry https://registry.npmmirror.com
cd ..

# 3. Start all services
docker-compose up -d

# 4. Wait 30-60 seconds for services to start
docker-compose ps

# 5. Access the application
# Frontend: http://localhost:3000
# API Gateway: http://localhost:8080
# Service Discovery: http://localhost:8761
```

### Verify Deployment
```bash
# Check all services are running
docker-compose ps

# View logs
docker-compose logs -f

# Test API
curl http://localhost:8080/actuator/health
```

---

## 🔐 Option 2: Secure Local Deployment

### Steps

```bash
# 1. Configure environment
cp .env.template .env
# Edit .env with your values

# 2. Generate secure passwords
openssl rand -base64 32 > secrets/mysql_root_password.txt
openssl rand -base64 32 > secrets/mysql_password.txt

# 3. Deploy with secrets
docker-compose -f docker-compose.security.yml up -d
```

---

## ☁️ Option 3: AWS ECS Deployment

### Prerequisites
- AWS CLI configured: `aws configure`
- Terraform installed
- Docker installed

### Steps

```bash
# 1. Navigate to infrastructure directory
cd infrastructure

# 2. Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 3. Initialize Terraform
terraform init

# 4. Review plan
terraform plan

# 5. Deploy infrastructure
terraform apply

# 6. Build and deploy applications
./deploy.sh

# 7. Get the Load Balancer URL
terraform output load_balancer_dns
```

### Access
- Frontend: `http://<load-balancer-dns>`
- API: `http://<load-balancer-dns>/api`

---

## ☸️ Option 4: AWS EKS Deployment

### Prerequisites
- AWS CLI configured: `aws configure`
- Terraform installed
- kubectl installed
- Docker installed

### Steps

```bash
# 1. Navigate to EKS infrastructure directory
cd eks-infrastructure

# 2. Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 3. Initialize Terraform
terraform init

# 4. Review plan
terraform plan

# 5. Deploy infrastructure
terraform apply

# 6. Build and deploy applications
./deploy-eks.sh

# 7. Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name banking-cluster

# 8. Get LoadBalancer URLs
kubectl get services -n banking-system
```

### Verify Deployment
```bash
# Check pods
kubectl get pods -n banking-system

# Check services
kubectl get services -n banking-system

# View logs
kubectl logs -f deployment/api-gateway -n banking-system
```

---

## 📊 Using the Application

### Create an Account
1. Open http://localhost:3000 (or your deployment URL)
2. Fill in the account creation form:
   - First Name
   - Last Name
   - Email (must be unique)
   - Phone Number (supports +1234567890, 08130262842, 1234567890)
   - Address
   - Gender
   - State of Origin
3. Click "Create Account"
4. Note the generated account number

### Check Balance
1. Switch to "Check Balance" tab
2. Enter your account number
3. View your account details and balance

### Make a Deposit
1. Switch to "Deposit" tab
2. Enter account number
3. Enter amount
4. Click "Deposit"

### Make a Withdrawal
1. Switch to "Withdraw" tab
2. Enter account number
3. Enter amount
4. Click "Withdraw"

### Transfer Money
1. Switch to "Transfer" tab
2. Enter source account number
3. Enter destination account number
4. Enter amount
5. Click "Transfer"

---

## 🔍 Health Checks

### Local Deployment
```bash
# Service Discovery
curl http://localhost:8761

# API Gateway
curl http://localhost:8080/actuator/health

# Account Service
curl http://localhost:8081/actuator/health

# Transaction Service
curl http://localhost:8082/actuator/health

# Notification Service
curl http://localhost:8083/actuator/health

# Audit Service
curl http://localhost:8084/actuator/health

# Database
docker exec banking-mysql mysqladmin ping -h localhost -u root -ppassword
```

### ECS Deployment
```bash
# Get Load Balancer DNS
LB_DNS=$(terraform output -raw load_balancer_dns)

# Check API Gateway
curl http://$LB_DNS/actuator/health

# Check Frontend
curl http://$LB_DNS
```

### EKS Deployment
```bash
# Check all pods
kubectl get pods -n banking-system

# Check services
kubectl get services -n banking-system

# Check logs
kubectl logs -f deployment/api-gateway -n banking-system
```

---

## 🛠️ Common Commands

### Docker Compose
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f [service-name]

# Restart a service
docker-compose restart [service-name]

# Rebuild and restart
docker-compose up -d --build

# Check status
docker-compose ps

# View resource usage
docker stats
```

### Terraform
```bash
# Initialize
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy

# View outputs
terraform output

# Format files
terraform fmt

# Validate configuration
terraform validate
```

### Kubernetes
```bash
# Get pods
kubectl get pods -n banking-system

# Get services
kubectl get services -n banking-system

# Get deployments
kubectl get deployments -n banking-system

# Describe pod
kubectl describe pod <pod-name> -n banking-system

# View logs
kubectl logs -f <pod-name> -n banking-system

# Scale deployment
kubectl scale deployment account-service --replicas=3 -n banking-system

# Delete pod (will be recreated)
kubectl delete pod <pod-name> -n banking-system

# Port forward
kubectl port-forward service/api-gateway 8080:8080 -n banking-system
```

---

## 🐛 Troubleshooting

### Services Not Starting
```bash
# Check Docker is running
docker ps

# Check port conflicts
netstat -tuln | grep -E '3000|8080|8761|3306'

# View service logs
docker-compose logs [service-name]

# Restart services
docker-compose restart
```

### Database Connection Issues
```bash
# Check MySQL is running
docker-compose ps mysql

# Check MySQL logs
docker-compose logs mysql

# Test connection
docker exec banking-mysql mysql -u root -ppassword -e "SELECT 1"
```

### Build Failures
```bash
# Pre-build microservices
cd microservices
./build-all.sh
cd ..

# Install webapp dependencies locally
cd webapp
npm install --registry https://registry.npmmirror.com
cd ..

# Rebuild specific service
docker-compose build [service-name]
```

### AWS Deployment Issues
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Check AWS region
aws configure get region

# View Terraform state
terraform show

# Check ECS services
aws ecs list-services --cluster banking-cluster

# Check EKS cluster
aws eks describe-cluster --name banking-cluster
```

---

## 📚 Additional Resources

- **Full Documentation**: [README.md](README.md)
- **Security Guidelines**: [SECURITY.md](SECURITY.md)
- **Deployment Status**: [DEPLOYMENT_STATUS.md](DEPLOYMENT_STATUS.md)
- **Implementation Status**: [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md)

---

## 🆘 Getting Help

1. Check the [Troubleshooting](#-troubleshooting) section
2. Review service logs: `docker-compose logs -f`
3. Check [DEPLOYMENT_STATUS.md](DEPLOYMENT_STATUS.md) for known issues
4. Review [SECURITY.md](SECURITY.md) for security-related issues

---

## 🎉 Success!

Once deployed, you should see:
- ✅ All services running
- ✅ Frontend accessible at http://localhost:3000
- ✅ API Gateway responding at http://localhost:8080
- ✅ Service Discovery dashboard at http://localhost:8761
- ✅ Database accepting connections

**Happy Banking! 🏦**
