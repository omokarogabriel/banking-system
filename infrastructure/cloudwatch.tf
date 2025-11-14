# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "banking_logs" {
  name              = "/ecs/banking-system"
  retention_in_days = 7

  tags = {
    Name = "banking-logs"
  }
}