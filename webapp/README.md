# Banking System Web Application

A React-based frontend for the banking system that connects to the Spring Boot backend.

## Features

- Create new bank accounts
- Check account balance
- Deposit money
- Withdraw money

## Setup

1. Install dependencies:
```bash
npm install
```

2. Start the development server:
```bash
npm start
```

The app will run on http://localhost:3000 and proxy API requests to the Spring Boot backend on http://localhost:8080.

## Backend Requirements

Make sure your Spring Boot banking application is running on port 8080 before using this webapp.

## Usage

1. **Create Account**: Fill in personal details to create a new bank account
2. **Check Balance**: Enter account number to view current balance
3. **Deposit**: Add money to an account
4. **Withdraw**: Remove money from an account

The webapp communicates with the backend API endpoints:
- POST `/api/user` - Create account
- GET `/api/user/balance/{accountNumber}` - Get balance
- POST `/api/user/deposit` - Deposit money
- POST `/api/user/withdraw` - Withdraw money