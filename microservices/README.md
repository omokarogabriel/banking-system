# Banking System Microservices Architecture

## Services Overview

### 1. Account Service
- User account management
- Account creation and validation
- Account balance inquiries

### 2. Transaction Service (New Feature)
- Money transfers between accounts
- Transaction history
- Transaction validation and processing

### 3. Notification Service (New Feature)
- Email notifications for transactions
- SMS notifications
- Event-driven notifications

### 4. API Gateway
- Single entry point for all client requests
- Load balancing and routing
- Authentication and authorization

### 5. Service Discovery
- Service registration and discovery
- Health checks and monitoring

## Technology Stack
- Spring Boot 3.4.0
- Spring Cloud Gateway
- Spring Cloud Netflix Eureka
- Spring Data JPA
- MySQL Database
- Docker & Docker Compose
- Maven

## Architecture Benefits
- Independent deployment and scaling
- Technology diversity
- Fault isolation
- Team autonomy
- Better maintainability