output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.banking_cluster.endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.banking_cluster.name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.banking_cluster.arn
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

output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.banking_cluster.name}"
}