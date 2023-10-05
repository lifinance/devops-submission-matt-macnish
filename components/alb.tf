resource "aws_lb" "falafel_alb" {
  name               = "falafel-alb"
  internal           = false # Setting to false because you probably want to access it from the Internet
  load_balancer_type = "application"
  security_groups    = [aws_security_group.falafel_alb_sg.id]
  subnets            = tolist(data.aws_subnets.public.ids)

  enable_deletion_protection = false

  tags = {
    Name = "falafel-alb"
  }
  depends_on = [
    module.api_vpc,
    data.aws_subnets.public
  ]
}

resource "aws_lb_target_group" "falafel_tg_3000" {
  name        = "falafle-tg-3000"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.api_vpc.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/status"
    port                = "3000"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "falafel_tg_5050" {
  name        = "falafel-tg-5050"
  port        = 5050
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.api_vpc.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/metrics"
    port                = "5050"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "falafel_listener_3000" {
  load_balancer_arn = aws_lb.falafel_alb.arn
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.falafel_tg_3000.arn
  }
}

resource "aws_lb_listener" "falafel_listener_5050" {
  load_balancer_arn = aws_lb.falafel_alb.arn
  port              = "5050"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.falafel_tg_5050.arn
  }
}

resource "aws_security_group" "falafel_alb_sg" {
  name        = "falafel-alb-sg"
  description = "Security group for Falafel ALB"
  vpc_id      = module.api_vpc.vpc_id

  tags = {
    Name = "falafel-alb-sg"
  }
}

resource "aws_security_group_rule" "alb_ingress_3000" {
  security_group_id = aws_security_group.falafel_alb_sg.id
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_ingress_5050" {
  security_group_id = aws_security_group.falafel_alb_sg.id
  type              = "ingress"
  from_port         = 5050
  to_port           = 5050
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "falafel_alb_egress" {
  security_group_id = aws_security_group.falafel_alb_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}