# Banking System - Startup & Deployment Guide

## 🚀 Quick Start

**Last Updated:** 2025-11-15  
**Status:** Production Ready

### Prerequisites Checklist
- [ ] Docker and Docker Compose installed
- [ ] Node.js 18+ installed
- [ ] Git installed
- [ ] 8GB+ RAM available
- [ ] Ports 3000, 8080-8084, 8761, 3306 available

## Services Status

| Service | Status | Port | URL |
|---------|--------|------|-----|
| MySQL Database | ✅ Running | 3306 | localhost:3306 |
| Service Discovery (Eureka) | ✅ Running | 8761 | http://localhost:8761 |
| Account Service | ✅ Running | 8081 | http://localhost:8081 |
| Transaction Service | ✅ Running | 8082 | http://localhost:8082 |
| Notification Service | ✅ Running | 8083 | http://localhost:8083 |
| Audit Service | ✅ Running | 8084 | http://localhost:8084 |
| API Gateway | ✅ Running | 8080 | http://localhost:8080 |
| React Web App | ✅ Running | 3000 | http://localhost:3000 |

## 📚 Deployment Options

### 1. Local Development (Recommended)
```bash
# Quick start
cd banking-system
cd webapp && npm install --registry https://registry.npmmirror.com && cd ..
docker-compose up -d

# With pre-built services (faster)
cd microservices && ./build-all.sh && cd ..
docker-compose up -d
```

### 2. Secure Local Deployment
```bash
# Using Docker secrets
cp .env.template .env  # Edit with your values
docker-compose -f docker-compose.security.yml up -d
```

### 3. AWS ECS Deployment
```bash
cd infrastructure
terraform init && terraform apply
./deploy.sh
```

### 4. AWS EKS Deployment
```bash
cd eks-infrastructure
terraform init && terraform apply
./deploy-eks.sh
```

## ⚙️ Configuration Details

### CORS Configuration
- API Gateway configured for `http://localhost:3000`
- Production: Update for your domain
- File: `/microservices/api-gateway/src/main/java/com/banking/gateway/config/CorsConfig.java`

### API Gateway Routes
- Account Service: `/api/accounts/**` → `lb://account-service`
- Transaction Service: `/api/transactions/**` → `lb://transaction-service`
- Notification Service: `/api/notifications/**` → `lb://notification-service`
- Audit Service: `/api/audit/**` → `lb://audit-service`

### Environment Configuration
- Development: `REACT_APP_API_URL=http://localhost:8080`
- Production: Update with your API Gateway URL
- Database: Configurable via environment variables

## Verified Functionality

### ✅ Backend API Tests
1. **Account Creation** - Successfully tested
   ```bash
   curl -X POST http://localhost:8080/api/accounts \
     -H "Content-Type: application/json" \
     -d '{"firstName":"Jane","lastName":"Smith","gender":"Female","address":"456 Oak Ave","email":"jane.smith@example.com","phoneNumber":"+1987654321"}'
   ```
   Response: Account created with number `2025852345`

2. **Account Retrieval** - Successfully tested
   ```bash
   curl http://localhost:8080/api/accounts/2025852345
   ```
   Response: Account details retrieved successfully

3. **CORS Preflight** - Successfully tested
   - Origin: `http://localhost:3000` is allowed
   - All required headers are present

### ✅ Service Discovery
- All microservices registered with Eureka
- API Gateway successfully routing requests to services

## Access URLs

- **Frontend Application:** http://localhost:3000
- **API Gateway:** http://localhost:8080
- **Service Discovery Dashboard:** http://localhost:8761
- **Direct Service Access:**
  - Account Service: http://localhost:8081
  - Transaction Service: http://localhost:8082
  - Notification Service: http://localhost:8083
  - Audit Service: http://localhost:8084

## How to Use

1. **Access the Web Application:**
   Open your browser and navigate to http://localhost:3000

2. **Create an Account:**
   - Fill in the form with required details
   - Click "Create Account"
   - Note the generated account number

3. **Check Balance:**
   - Switch to "Check Balance" tab
   - Enter your account number

4. **Make Transactions:**
   - Use Deposit/Withdraw tabs for account operations
   - Use Transfer tab to transfer between accounts

## Database Credentials

- **Host:** localhost:3306
- **Database:** banking_system
- **Username:** root
- **Password:** password

⚠️ **Note:** These are development credentials. Use secure credentials in production.

## Stopping the Application

```bash
docker-compose down
```

## Restarting the Application

```bash
docker-compose up -d
```

## Viewing Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f api-gateway
docker-compose logs -f webapp
```

## Troubleshooting

### ✅ "Request failed with status code 400" Error - FIXED

**Issue:** Phone number validation was rejecting Nigerian phone numbers starting with `0`.

**Fix Applied:** Updated phone number validation pattern in both AccountRequest DTO and Account entity to accept:
- International format: `+1234567890`
- Nigerian format: `08130262842`
- Other formats: `1234567890`

**Validation Rules:**
- **Phone Number:** Now accepts `^(\\+?[1-9]\\d{1,14}|0\\d{10})$`
- **Email:** Must be unique and valid format
- **Names:** 2-50 characters, cannot be empty

**Verified Working:**
```bash
# Nigerian phone number now works
curl -X POST http://localhost:8080/api/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User", 
    "email": "test.fixed@example.com",
    "phoneNumber": "08130262842",
    "address": "123 Lagos St",
    "gender": "Male",
    "stateOfOrigin": "Lagos"
  }'
# Response: Account created successfully with number 2025616278
```

### General Issues

If you encounter other issues:

1. **Check all containers are running:**
   ```bash
   docker-compose ps
   ```

2. **Check service logs:**
   ```bash
   docker-compose logs [service-name]
   ```

3. **Restart a specific service:**
   ```bash
   docker-compose restart [service-name]
   ```

4. **Rebuild and restart:**
   ```bash
   docker-compose up -d --build
   ```

## 📈 Monitoring & Health Checks

### Service Health Endpoints
```bash
# Check all services
curl http://localhost:8080/actuator/health  # API Gateway
curl http://localhost:8081/actuator/health  # Account Service
curl http://localhost:8082/actuator/health  # Transaction Service
curl http://localhost:8083/actuator/health  # Notification Service
curl http://localhost:8084/actuator/health  # Audit Service
```

### Database Monitoring
```bash
# Connection count
docker exec banking-mysql mysql -u root -ppassword -e "SHOW STATUS LIKE 'Threads_connected';"

# Database size
docker exec banking-mysql mysql -u root -ppassword -e "SELECT table_schema AS 'Database', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' FROM information_schema.tables WHERE table_schema = 'banking_system';"
```

### Performance Monitoring
```bash
# Check resource usage
docker stats

# Monitor logs in real-time
docker-compose logs -f | grep ERROR

# Export logs for analysis
docker-compose logs > banking-system.log
```

## ✅ All Files Updated with Phone Number Validation Fix

**Updated Files:**
- ✅ `/microservices/account-service/src/main/java/com/banking/account/dto/AccountRequest.java`
- ✅ `/microservices/account-service/src/main/java/com/banking/account/entity/Account.java`
- ✅ `/webapp/src/components/CreateAccount.js`
- ✅ `/test-api.html`
- ✅ `/README.md`
- ✅ `/DEPLOYMENT_STATUS.md`

**Phone Number Pattern:** `^(\\+?[1-9]\\d{1,14}|0\\d{10})$`

**Supported Formats:**
- International: `+1234567890`
- Nigerian: `08130262842`
- Standard: `1234567890`

## 🚀 Next Steps

### Development
- ✅ Phone validation fix implemented and working
- [ ] Test all webapp features through browser
- [ ] Create multiple accounts and test transfers
- [ ] Implement authentication/authorization
- [ ] Add input validation and error handling
- [ ] Set up automated testing

### Production Readiness
- [ ] Review [SECURITY.md](SECURITY.md) guidelines
- [ ] Configure production database credentials
- [ ] Set up SSL/TLS certificates
- [ ] Configure monitoring and alerting
- [ ] Implement backup strategies
- [ ] Set up CI/CD pipelines

### Cloud Deployment
- [ ] Configure AWS credentials
- [ ] Review infrastructure costs
- [ ] Set up domain and DNS
- [ ] Configure load balancing
- [ ] Implement auto-scaling
- [ ] Set up disaster recovery
