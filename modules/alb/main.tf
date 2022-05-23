resource "aws_lb" "alb" {
  name               = "${var.tag_name_prefix}-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    "${aws_security_group.security_group_alb.id}"
  ]
  subnets = [
    "${var.public_subnet1_id}",
    "${var.public_subnet2_id}"
  ]

  tags = {
    Name = "${var.tag_name_prefix}-alb"
  }
}

resource "aws_lb_target_group" "target_group" {
  name = "target-group"
  depends_on = [
    var.vpc
  ]
  port     = "80"
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    interval            = 70
    path                = "/index.html"
    port                = 80
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 60
    protocol            = "HTTP"
    matcher             = "200"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_security_group" "security_group_alb" {
  name        = "Application Load Balancer Security Group"
  description = "Security Group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow Inbound HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Inbound SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allows SSH and ALL egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.tag_name_prefix}-alb-sg"
  }
}

