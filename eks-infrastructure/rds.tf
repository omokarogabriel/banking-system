# RDS Subnet Group
resource "aws_db_subnet_group" "banking_db_subnet_group" {
  name       = "banking-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "banking-db-subnet-group"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "banking-rds-sg"
  description = "Security group for RDS MySQL"
  vpc_id      = aws_vpc.banking_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.banking_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "banking-rds-sg"
  }
}

# KMS Key for RDS Encryption
resource "aws_kms_key" "rds_key" {
  description = "KMS key for RDS encryption"
  
  tags = {
    Name = "banking-rds-key"
  }
}

resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/banking-rds-key"
  target_key_id = aws_kms_key.rds_key.key_id
}

# RDS MySQL Instance
resource "aws_db_instance" "banking_db" {
  identifier             = "banking-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  
  # Security enhancements
  storage_encrypted               = true
  kms_key_id                     = aws_kms_key.rds_key.arn
  iam_database_authentication_enabled = true
  
  # Backup and maintenance
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring_role.arn
  
  # Performance Insights
  performance_insights_enabled = true
  performance_insights_kms_key_id = aws_kms_key.rds_key.arn
  
  db_name  = "banking_system"
  username = "root"
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.banking_db_subnet_group.name
  
  skip_final_snapshot = true
  
  tags = {
    Name = "banking-mysql"
  }
}

# IAM Role for RDS Monitoring
resource "aws_iam_role" "rds_monitoring_role" {
  name = "rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}