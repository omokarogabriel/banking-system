output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.banking_alb.dns_name
}

output "database_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.banking_db.endpoint
}

output "ecr_repositories" {
  description = "ECR repository URLs"
  value = {
    service_discovery    = aws_ecr_repository.service_discovery.repository_url
    account_service     = aws_ecr_repository.account_service.repository_url
    transaction_service = aws_ecr_repository.transaction_service.repository_url
    notification_service = aws_ecr_repository.notification_service.repository_url
    audit_service       = aws_ecr_repository.audit_service.repository_url
    api_gateway         = aws_ecr_repository.api_gateway.repository_url
    webapp              = aws_ecr_repository.webapp.repository_url
  }
}