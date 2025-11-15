# Banking System - Testing Guide

Comprehensive testing guide for the banking system.

---

## 🧪 Testing Levels

### 1. Local Development Testing
### 2. API Testing
### 3. Integration Testing
### 4. Load Testing
### 5. Security Testing

---

## 🏠 Local Development Testing

### Prerequisites
```bash
# Ensure all services are running
docker-compose ps

# All services should show "Up" status
```

### Test Service Health

```bash
# Service Discovery (Eureka)
curl http://localhost:8761
# Expected: Eureka dashboard HTML

# API Gateway
curl http://localhost:8080/actuator/health
# Expected: {"status":"UP"}

# Account Service
curl http://localhost:8081/actuator/health
# Expected: {"status":"UP"}

# Transaction Service
curl http://localhost:8082/actuator/health
# Expected: {"status":"UP"}

# Notification Service
curl http://localhost:8083/actuator/health
# Expected: {"status":"UP"}

# Audit Service
curl http://localhost:8084/actuator/health
# Expected: {"status":"UP"}
```

### Test Database Connection

```bash
# Ping MySQL
docker exec banking-mysql mysqladmin ping -h localhost -u root -ppassword
# Expected: mysqld is alive

# Check database exists
docker exec banking-mysql mysql -u root -ppassword -e "SHOW DATABASES;"
# Expected: banking_system in the list

# Check tables
docker exec banking-mysql mysql -u root -ppassword banking_system -e "SHOW TABLES;"
# Expected: accounts, transactions, audit_logs tables
```

---

## 🔌 API Testing

### Account Service Tests

#### Create Account
```bash
curl -X POST http://localhost:8080/api/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "phoneNumber": "+1234567890",
    "address": "123 Main St",
    "gender": "Male",
    "stateOfOrigin": "California"
  }'

# Expected Response:
# {
#   "accountNumber": "2025123456",
#   "firstName": "John",
#   "lastName": "Doe",
#   "email": "john.doe@example.com",
#   "balance": 0.0,
#   ...
# }
```

#### Get Account by Number
```bash
curl http://localhost:8080/api/accounts/2025123456

# Expected: Account details with balance
```

#### Get All Accounts
```bash
curl http://localhost:8080/api/accounts

# Expected: Array of all accounts
```

#### Update Account
```bash
curl -X PUT http://localhost:8080/api/accounts/2025123456 \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.updated@example.com",
    "phoneNumber": "+1234567890",
    "address": "456 Oak Ave",
    "gender": "Male",
    "stateOfOrigin": "California"
  }'

# Expected: Updated account details
```

#### Delete Account
```bash
curl -X DELETE http://localhost:8080/api/accounts/2025123456

# Expected: 204 No Content
```

### Transaction Service Tests

#### Deposit
```bash
curl -X POST http://localhost:8080/api/transactions/deposit \
  -H "Content-Type: application/json" \
  -d '{
    "accountNumber": "2025123456",
    "amount": 1000.00
  }'

# Expected: Transaction confirmation with new balance
```

#### Withdraw
```bash
curl -X POST http://localhost:8080/api/transactions/withdraw \
  -H "Content-Type: application/json" \
  -d '{
    "accountNumber": "2025123456",
    "amount": 100.00
  }'

# Expected: Transaction confirmation with new balance
```

#### Transfer
```bash
curl -X POST http://localhost:8080/api/transactions/transfer \
  -H "Content-Type: application/json" \
  -d '{
    "fromAccountNumber": "2025123456",
    "toAccountNumber": "2025789012",
    "amount": 50.00
  }'

# Expected: Transaction confirmation with updated balances
```

#### Get Transaction History
```bash
curl http://localhost:8080/api/transactions/account/2025123456

# Expected: Array of transactions for the account
```

### Phone Number Validation Tests

```bash
# Test International Format
curl -X POST http://localhost:8080/api/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User",
    "email": "test1@example.com",
    "phoneNumber": "+1234567890",
    "address": "123 Test St",
    "gender": "Male",
    "stateOfOrigin": "Test"
  }'
# Expected: Success

# Test Nigerian Format
curl -X POST http://localhost:8080/api/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User",
    "email": "test2@example.com",
    "phoneNumber": "08130262842",
    "address": "123 Test St",
    "gender": "Male",
    "stateOfOrigin": "Lagos"
  }'
# Expected: Success

# Test Standard Format
curl -X POST http://localhost:8080/api/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User",
    "email": "test3@example.com",
    "phoneNumber": "1234567890",
    "address": "123 Test St",
    "gender": "Male",
    "stateOfOrigin": "Test"
  }'
# Expected: Success

# Test Invalid Format
curl -X POST http://localhost:8080/api/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User",
    "email": "test4@example.com",
    "phoneNumber": "invalid",
    "address": "123 Test St",
    "gender": "Male",
    "stateOfOrigin": "Test"
  }'
# Expected: 400 Bad Request with validation error
```

---

## 🔗 Integration Testing

### End-to-End Account Lifecycle

```bash
# 1. Create Account
ACCOUNT=$(curl -s -X POST http://localhost:8080/api/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Integration",
    "lastName": "Test",
    "email": "integration@test.com",
    "phoneNumber": "+9876543210",
    "address": "123 Integration St",
    "gender": "Female",
    "stateOfOrigin": "Test"
  }')

ACCOUNT_NUMBER=$(echo $ACCOUNT | jq -r '.accountNumber')
echo "Created account: $ACCOUNT_NUMBER"

# 2. Verify Account Creation
curl http://localhost:8080/api/accounts/$ACCOUNT_NUMBER

# 3. Deposit Money
curl -X POST http://localhost:8080/api/transactions/deposit \
  -H "Content-Type: application/json" \
  -d "{
    \"accountNumber\": \"$ACCOUNT_NUMBER\",
    \"amount\": 5000.00
  }"

# 4. Check Balance
curl http://localhost:8080/api/accounts/$ACCOUNT_NUMBER

# 5. Withdraw Money
curl -X POST http://localhost:8080/api/transactions/withdraw \
  -H "Content-Type: application/json" \
  -d "{
    \"accountNumber\": \"$ACCOUNT_NUMBER\",
    \"amount\": 1000.00
  }"

# 6. Check Transaction History
curl http://localhost:8080/api/transactions/account/$ACCOUNT_NUMBER

# 7. Update Account
curl -X PUT http://localhost:8080/api/accounts/$ACCOUNT_NUMBER \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Integration",
    "lastName": "Updated",
    "email": "integration.updated@test.com",
    "phoneNumber": "+9876543210",
    "address": "456 Updated St",
    "gender": "Female",
    "stateOfOrigin": "Test"
  }'

# 8. Delete Account
curl -X DELETE http://localhost:8080/api/accounts/$ACCOUNT_NUMBER
```

### Transfer Between Accounts

```bash
# Create two accounts
ACCOUNT1=$(curl -s -X POST http://localhost:8080/api/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Sender",
    "lastName": "Account",
    "email": "sender@test.com",
    "phoneNumber": "+1111111111",
    "address": "123 Sender St",
    "gender": "Male",
    "stateOfOrigin": "Test"
  }')

ACCOUNT2=$(curl -s -X POST http://localhost:8080/api/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Receiver",
    "lastName": "Account",
    "email": "receiver@test.com",
    "phoneNumber": "+2222222222",
    "address": "123 Receiver St",
    "gender": "Female",
    "stateOfOrigin": "Test"
  }')

ACC1_NUM=$(echo $ACCOUNT1 | jq -r '.accountNumber')
ACC2_NUM=$(echo $ACCOUNT2 | jq -r '.accountNumber')

# Deposit to first account
curl -X POST http://localhost:8080/api/transactions/deposit \
  -H "Content-Type: application/json" \
  -d "{
    \"accountNumber\": \"$ACC1_NUM\",
    \"amount\": 10000.00
  }"

# Transfer between accounts
curl -X POST http://localhost:8080/api/transactions/transfer \
  -H "Content-Type: application/json" \
  -d "{
    \"fromAccountNumber\": \"$ACC1_NUM\",
    \"toAccountNumber\": \"$ACC2_NUM\",
    \"amount\": 2500.00
  }"

# Verify balances
echo "Account 1 balance:"
curl http://localhost:8080/api/accounts/$ACC1_NUM | jq '.balance'

echo "Account 2 balance:"
curl http://localhost:8080/api/accounts/$ACC2_NUM | jq '.balance'
```

---

## ⚡ Load Testing

### Using Apache Bench

```bash
# Install Apache Bench
sudo apt-get install apache2-utils  # Ubuntu/Debian
brew install httpd  # macOS

# Test Account Creation (100 requests, 10 concurrent)
ab -n 100 -c 10 -p account.json -T application/json \
  http://localhost:8080/api/accounts

# Test Get Account (1000 requests, 50 concurrent)
ab -n 1000 -c 50 http://localhost:8080/api/accounts/2025123456

# Test Deposit (500 requests, 25 concurrent)
ab -n 500 -c 25 -p deposit.json -T application/json \
  http://localhost:8080/api/transactions/deposit
```

### Sample JSON Files for Load Testing

**account.json**
```json
{
  "firstName": "Load",
  "lastName": "Test",
  "email": "load.test@example.com",
  "phoneNumber": "+1234567890",
  "address": "123 Load Test St",
  "gender": "Male",
  "stateOfOrigin": "Test"
}
```

**deposit.json**
```json
{
  "accountNumber": "2025123456",
  "amount": 100.00
}
```

### Using JMeter

1. Download Apache JMeter
2. Create a test plan with:
   - Thread Group (users)
   - HTTP Request samplers
   - Listeners for results
3. Configure endpoints and payloads
4. Run test and analyze results

---

## 🔒 Security Testing

### SQL Injection Tests

```bash
# Test SQL injection in account number
curl "http://localhost:8080/api/accounts/2025123456' OR '1'='1"
# Expected: 404 Not Found or proper error handling

# Test SQL injection in email
curl -X POST http://localhost:8080/api/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User",
    "email": "test@example.com'\'' OR '\''1'\''='\''1",
    "phoneNumber": "+1234567890",
    "address": "123 Test St",
    "gender": "Male",
    "stateOfOrigin": "Test"
  }'
# Expected: 400 Bad Request with validation error
```

### XSS Tests

```bash
# Test XSS in firstName
curl -X POST http://localhost:8080/api/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "<script>alert(\"XSS\")</script>",
    "lastName": "User",
    "email": "xss@example.com",
    "phoneNumber": "+1234567890",
    "address": "123 Test St",
    "gender": "Male",
    "stateOfOrigin": "Test"
  }'
# Expected: Input should be sanitized or rejected
```

### Authentication Tests

```bash
# Test unauthorized access (if auth is implemented)
curl -X DELETE http://localhost:8080/api/accounts/2025123456
# Expected: 401 Unauthorized (if auth is enabled)
```

---

## 📊 Monitoring Tests

### Check Service Discovery

```bash
# View registered services
curl http://localhost:8761/eureka/apps
# Expected: XML with all registered services

# Check specific service
curl http://localhost:8761/eureka/apps/ACCOUNT-SERVICE
# Expected: Account service instances
```

### Check Metrics

```bash
# API Gateway metrics
curl http://localhost:8080/actuator/metrics

# Account Service metrics
curl http://localhost:8081/actuator/metrics

# Specific metric
curl http://localhost:8080/actuator/metrics/http.server.requests
```

### Database Monitoring

```bash
# Check active connections
docker exec banking-mysql mysql -u root -ppassword \
  -e "SHOW STATUS LIKE 'Threads_connected';"

# Check database size
docker exec banking-mysql mysql -u root -ppassword \
  -e "SELECT table_schema AS 'Database', 
      ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' 
      FROM information_schema.tables 
      WHERE table_schema = 'banking_system';"

# Check table row counts
docker exec banking-mysql mysql -u root -ppassword banking_system \
  -e "SELECT 
      (SELECT COUNT(*) FROM accounts) AS accounts,
      (SELECT COUNT(*) FROM transactions) AS transactions,
      (SELECT COUNT(*) FROM audit_logs) AS audit_logs;"
```

---

## 🧹 Cleanup After Testing

```bash
# Stop all services
docker-compose down

# Remove volumes (WARNING: deletes all data)
docker-compose down -v

# Remove all test accounts
docker exec banking-mysql mysql -u root -ppassword banking_system \
  -e "DELETE FROM accounts WHERE email LIKE '%test%';"

# Reset database
docker-compose down -v
docker-compose up -d
```

---

## ✅ Test Checklist

### Functional Tests
- [ ] Create account with valid data
- [ ] Create account with invalid data (should fail)
- [ ] Get account by number
- [ ] Get all accounts
- [ ] Update account
- [ ] Delete account
- [ ] Deposit money
- [ ] Withdraw money
- [ ] Transfer between accounts
- [ ] Get transaction history

### Validation Tests
- [ ] Phone number - international format
- [ ] Phone number - Nigerian format
- [ ] Phone number - standard format
- [ ] Phone number - invalid format (should fail)
- [ ] Email - valid format
- [ ] Email - invalid format (should fail)
- [ ] Email - duplicate (should fail)
- [ ] Amount - positive values
- [ ] Amount - negative values (should fail)
- [ ] Amount - zero (should fail)

### Integration Tests
- [ ] Service discovery registration
- [ ] API Gateway routing
- [ ] Database connectivity
- [ ] Transaction rollback on error
- [ ] Concurrent transactions
- [ ] Account balance consistency

### Performance Tests
- [ ] Response time < 200ms for reads
- [ ] Response time < 500ms for writes
- [ ] Handle 100 concurrent users
- [ ] Handle 1000 requests per minute
- [ ] Database connection pooling

### Security Tests
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] CORS configuration
- [ ] Input validation
- [ ] Error message sanitization

---

## 📝 Test Results Template

```markdown
## Test Execution Report

**Date**: YYYY-MM-DD
**Tester**: Your Name
**Environment**: Local/ECS/EKS

### Test Summary
- Total Tests: X
- Passed: X
- Failed: X
- Skipped: X

### Failed Tests
1. Test Name
   - Expected: ...
   - Actual: ...
   - Error: ...

### Performance Metrics
- Average Response Time: Xms
- Max Response Time: Xms
- Throughput: X req/sec

### Notes
- Any observations or issues
```

---

## 🔄 Continuous Testing

### Automated Testing Script

```bash
#!/bin/bash
# test-all.sh

echo "Starting Banking System Tests..."

# Health checks
echo "1. Testing service health..."
curl -f http://localhost:8080/actuator/health || exit 1

# Create account
echo "2. Testing account creation..."
RESPONSE=$(curl -s -X POST http://localhost:8080/api/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Auto",
    "lastName": "Test",
    "email": "auto.test@example.com",
    "phoneNumber": "+1234567890",
    "address": "123 Auto St",
    "gender": "Male",
    "stateOfOrigin": "Test"
  }')

ACCOUNT_NUMBER=$(echo $RESPONSE | jq -r '.accountNumber')
echo "Created account: $ACCOUNT_NUMBER"

# Deposit
echo "3. Testing deposit..."
curl -s -X POST http://localhost:8080/api/transactions/deposit \
  -H "Content-Type: application/json" \
  -d "{
    \"accountNumber\": \"$ACCOUNT_NUMBER\",
    \"amount\": 1000.00
  }" > /dev/null

# Verify balance
echo "4. Verifying balance..."
BALANCE=$(curl -s http://localhost:8080/api/accounts/$ACCOUNT_NUMBER | jq -r '.balance')
if [ "$BALANCE" == "1000.0" ]; then
  echo "✅ All tests passed!"
else
  echo "❌ Balance test failed. Expected 1000.0, got $BALANCE"
  exit 1
fi
```

Make it executable:
```bash
chmod +x test-all.sh
./test-all.sh
```

---

**Happy Testing! 🧪**
