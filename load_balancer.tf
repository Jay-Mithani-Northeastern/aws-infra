resource "aws_lb" "application_loadbalancer" {
  name               = "applicationlb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.loadbalancer_securitygroup.id]
  subnets            = [for subnet in aws_subnet.public_subnet : subnet.id]
  tags = {
    Application = "WebApp"
  }
}

resource "aws_lb_target_group" "loadbalancer_targetgroup" {
  name     = "lbtg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  health_check {
    path = "/healthz"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.application_loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.loadbalancer_targetgroup.arn
  }
}

resource "aws_security_group" "loadbalancer_securitygroup" {
  name_prefix = "application_lb_sg"
  vpc_id      = aws_vpc.vpc.id

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
}

resource "aws_security_group_rule" "to_ec2" {
  type                     = "egress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.loadbalancer_securitygroup.id
  source_security_group_id = aws_security_group.instance.id
}
