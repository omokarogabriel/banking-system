# ECR Repositories
resource "aws_ecr_repository" "service_discovery" {
  name = "banking/service-discovery"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "account_service" {
  name = "banking/account-service"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "transaction_service" {
  name = "banking/transaction-service"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "notification_service" {
  name = "banking/notification-service"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "audit_service" {
  name = "banking/audit-service"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "api_gateway" {
  name = "banking/api-gateway"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "webapp" {
  name = "banking/webapp"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}