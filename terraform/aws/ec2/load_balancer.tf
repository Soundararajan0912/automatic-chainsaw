# Application Load Balancer Configuration

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb"
  })
}

# Target Group for HTTP
resource "aws_lb_target_group" "http" {
  name     = "${substr(var.project_name, 0, 20)}-${var.environment}-http-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-http-tg"
  })
}

# Target Group for HTTPS (if needed)
resource "aws_lb_target_group" "https" {
  name     = "${substr(var.project_name, 0, 19)}-${var.environment}-https-tg"
  port     = 443
  protocol = "HTTP" # Backend is HTTP, SSL termination at ALB
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
    port                = "80" # Health check on HTTP port
    protocol            = "HTTP"
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-https-tg"
  })
}

# Target Group for Jenkins
resource "aws_lb_target_group" "jenkins" {
  name     = "${substr(var.project_name, 0, 15)}-${var.environment}-jenkins-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 10
    interval            = 30
    path                = "/login"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-jenkins-tg"
  })
}

# Target Group Attachment for HTTP
resource "aws_lb_target_group_attachment" "http" {
  count = length(aws_instance.main)

  target_group_arn = aws_lb_target_group.http.arn
  target_id        = aws_instance.main[count.index].id
  port             = 80
}

# Target Group Attachment for HTTPS
resource "aws_lb_target_group_attachment" "https" {
  count = length(aws_instance.main)

  target_group_arn = aws_lb_target_group.https.arn
  target_id        = aws_instance.main[count.index].id
  port             = 80 # Backend serves HTTP, SSL terminated at ALB
}

# Target Group Attachment for Jenkins
resource "aws_lb_target_group_attachment" "jenkins" {
  count = length(aws_instance.main)

  target_group_arn = aws_lb_target_group.jenkins.arn
  target_id        = aws_instance.main[count.index].id
  port             = 8080
}

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-http-listener"
  })
}

# HTTPS Listener (redirects to HTTP for now, add SSL certificate as needed)
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTP" # Change to HTTPS when SSL certificate is added

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-https-listener"
  })
}

# Jenkins Listener (Port 8080)
resource "aws_lb_listener" "jenkins" {
  load_balancer_arn = aws_lb.main.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-jenkins-listener"
  })
}

# Note: To enable HTTPS with SSL certificate, uncomment and configure:
# 
# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
#   certificate_arn   = aws_acm_certificate.main.arn
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.https.arn
#   }
# }
#
# # Redirect HTTP to HTTPS
# resource "aws_lb_listener" "http_redirect" {
#   load_balancer_arn = aws_lb.main.arn
#   port              = "80"
#   protocol          = "HTTP"
#
#   default_action {
#     type = "redirect"
#
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }