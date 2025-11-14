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

# RDS MySQL Instance
resource "aws_db_instance" "banking_db" {
  identifier             = "banking-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  
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