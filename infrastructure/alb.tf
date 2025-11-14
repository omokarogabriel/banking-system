# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "banking-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.banking_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "banking-alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "banking_alb" {
  name               = "banking-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "banking-alb"
  }
}

# Target Groups
resource "aws_lb_target_group" "webapp_tg" {
  name     = "banking-webapp-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.banking_vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "api_gateway_tg" {
  name     = "banking-api-gateway-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.banking_vpc.id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/actuator/health"
    matcher             = "200"
  }
}

# ALB Listeners
resource "aws_lb_listener" "webapp_listener" {
  load_balancer_arn = aws_lb.banking_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
}

resource "aws_lb_listener_rule" "api_rule" {
  listener_arn = aws_lb_listener.webapp_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_gateway_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}