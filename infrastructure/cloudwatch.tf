# KMS Key for CloudWatch Logs
resource "aws_kms_key" "cloudwatch_key" {
  description = "KMS key for CloudWatch logs encryption"
  
  tags = {
    Name = "banking-cloudwatch-key"
  }
}

resource "aws_kms_alias" "cloudwatch_key_alias" {
  name          = "alias/banking-cloudwatch-key"
  target_key_id = aws_kms_key.cloudwatch_key.key_id
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "banking_logs" {
  name              = "/ecs/banking-system"
  retention_in_days = 30
  kms_key_id        = aws_kms_key.cloudwatch_key.arn

  tags = {
    Name = "banking-logs"
  }
}