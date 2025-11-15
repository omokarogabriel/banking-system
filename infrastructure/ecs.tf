# ECS Cluster
resource "aws_ecs_cluster" "banking_cluster" {
  name = "banking-cluster"

  tags = {
    Name = "banking-cluster"
  }
}

# Security Group for ECS
resource "aws_security_group" "ecs_sg" {
  name        = "banking-ecs-sg"
  description = "Security group for ECS services"
  vpc_id      = aws_vpc.banking_vpc.id

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "banking-ecs-sg"
  }
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "banking-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task Definitions
resource "aws_ecs_task_definition" "service_discovery" {
  family                   = "service-discovery"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "service-discovery"
      image = "${aws_ecr_repository.service_discovery.repository_url}:latest"
      portMappings = [
        {
          containerPort = 8761
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.banking_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "service-discovery"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "account_service" {
  family                   = "account-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "account-service"
      image = "${aws_ecr_repository.account_service.repository_url}:latest"
      portMappings = [
        {
          containerPort = 8081
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "DB_USERNAME"
          value = "root"
        },
        {
          name  = "DB_PASSWORD"
          value = var.db_password
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.banking_db.endpoint
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.banking_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "account-service"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "transaction_service" {
  family                   = "transaction-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "transaction-service"
      image = "${aws_ecr_repository.transaction_service.repository_url}:latest"
      portMappings = [
        {
          containerPort = 8082
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "DB_USERNAME"
          value = "root"
        },
        {
          name  = "DB_PASSWORD"
          value = var.db_password
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.banking_db.endpoint
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.banking_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "transaction-service"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "notification_service" {
  family                   = "notification-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "notification-service"
      image = "${aws_ecr_repository.notification_service.repository_url}:latest"
      portMappings = [
        {
          containerPort = 8083
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.banking_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "notification-service"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "audit_service" {
  family                   = "audit-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "audit-service"
      image = "${aws_ecr_repository.audit_service.repository_url}:latest"
      portMappings = [
        {
          containerPort = 8084
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "DB_USERNAME"
          value = "root"
        },
        {
          name  = "DB_PASSWORD"
          value = var.db_password
        },
        {
          name  = "DB_HOST"
          value = aws_db_instance.banking_db.endpoint
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.banking_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "audit-service"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "api_gateway" {
  family                   = "api-gateway"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "api-gateway"
      image = "${aws_ecr_repository.api_gateway.repository_url}:latest"
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.banking_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "api-gateway"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "webapp" {
  family                   = "webapp"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "webapp"
      image = "${aws_ecr_repository.webapp.repository_url}:latest"
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "REACT_APP_API_URL"
          value = "http://${aws_lb.banking_alb.dns_name}"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.banking_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "webapp"
        }
      }
    }
  ])
}

# ECS Services
resource "aws_ecs_service" "service_discovery" {
  name            = "service-discovery"
  cluster         = aws_ecs_cluster.banking_cluster.id
  task_definition = aws_ecs_task_definition.service_discovery.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }
}

resource "aws_ecs_service" "account_service" {
  name            = "account-service"
  cluster         = aws_ecs_cluster.banking_cluster.id
  task_definition = aws_ecs_task_definition.account_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  depends_on = [aws_ecs_service.service_discovery]
}

resource "aws_ecs_service" "transaction_service" {
  name            = "transaction-service"
  cluster         = aws_ecs_cluster.banking_cluster.id
  task_definition = aws_ecs_task_definition.transaction_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  depends_on = [aws_ecs_service.account_service]
}

resource "aws_ecs_service" "notification_service" {
  name            = "notification-service"
  cluster         = aws_ecs_cluster.banking_cluster.id
  task_definition = aws_ecs_task_definition.notification_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  depends_on = [aws_ecs_service.service_discovery]
}

resource "aws_ecs_service" "audit_service" {
  name            = "audit-service"
  cluster         = aws_ecs_cluster.banking_cluster.id
  task_definition = aws_ecs_task_definition.audit_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  depends_on = [aws_ecs_service.service_discovery]
}

resource "aws_ecs_service" "api_gateway" {
  name            = "api-gateway"
  cluster         = aws_ecs_cluster.banking_cluster.id
  task_definition = aws_ecs_task_definition.api_gateway.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api_gateway_tg.arn
    container_name   = "api-gateway"
    container_port   = 8080
  }

  depends_on = [aws_ecs_service.account_service]
}

resource "aws_ecs_service" "webapp" {
  name            = "webapp"
  cluster         = aws_ecs_cluster.banking_cluster.id
  task_definition = aws_ecs_task_definition.webapp.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.webapp_tg.arn
    container_name   = "webapp"
    container_port   = 3000
  }

  depends_on = [aws_ecs_service.api_gateway]
}