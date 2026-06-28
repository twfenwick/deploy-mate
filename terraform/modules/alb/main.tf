# ALB security group
resource "aws_security_group" "alb" {
  name   = "deploy-mate-alb-sg"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "alb" {
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb" {
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# ALB
resource "aws_lb" "deploy_mate" {
  name               = "deploy-mate-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "deploy_mate" {
  name        = "deploy-mate-tg"
  port        = 8087
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip" # required for Fargate

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_listener" "deploy_mate" {
  load_balancer_arn = aws_lb.deploy_mate.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.deploy_mate.arn
  }
}

# Route 53
data "aws_route53_zone" "this" {
  name = "timfenwick.com" # replace with your domain
}

resource "aws_route53_record" "deploy_mate" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "bunny.timfenwick.com" # or just "yourdomain.com" for apex
  type    = "A"

  alias {
    name                   = aws_lb.deploy_mate.dns_name
    zone_id                = aws_lb.deploy_mate.zone_id
    evaluate_target_health = true
  }
}
