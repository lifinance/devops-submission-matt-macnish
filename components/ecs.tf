resource "aws_ecs_cluster" "fargate_cluster" {
  name = "falafelapi-cluster"
}

resource "aws_security_group" "falafelapi_sg" {
  name        = "falafelapi-sg"
  description = "Allow traffic for Falafel API"
  vpc_id      = module.api_vpc.vpc_id
}
resource "aws_security_group_rule" "falafel_ingress_3000" {
  for_each          = toset(module.api_vpc.private_subnet_CIDR)
  security_group_id = aws_security_group.falafelapi_sg.id
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = [each.key]
}

resource "aws_security_group_rule" "falafel_ingress_5050" {
  for_each          = toset(module.api_vpc.private_subnet_CIDR)
  security_group_id = aws_security_group.falafelapi_sg.id
  type              = "ingress"
  from_port         = 5050
  to_port           = 5050
  protocol          = "tcp"
  cidr_blocks       = [each.key]
}

resource "aws_security_group_rule" "alb_ecs_ingress_3000" {
  security_group_id        = aws_security_group.falafelapi_sg.id
  type                     = "ingress"
  from_port                = 3000
  to_port                  = 3000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.falafel_alb_sg.id

  depends_on = [aws_security_group.falafel_alb_sg]
}

resource "aws_security_group_rule" "alb_ecs_ingress_5050" {
  security_group_id        = aws_security_group.falafelapi_sg.id
  type                     = "ingress"
  from_port                = 5050
  to_port                  = 5050
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.falafel_alb_sg.id

  depends_on = [aws_security_group.falafel_alb_sg]
}

resource "aws_security_group_rule" "falafel_egress" {
  security_group_id = aws_security_group.falafelapi_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "falafelapi" {
  family                   = "falafelapi"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.api_ecs_role.arn
  task_role_arn            = aws_iam_role.api_ecs_role.arn

  container_definitions = jsonencode([{
    name  = "falafelapi"
    image = "${data.aws_ecr_repository.falafel_ecr.repository_url}:latest"

    portMappings = [
      {
        containerPort = 3000
        hostPort      = 3000
      },
      {
        containerPort = 5050
        hostPort      = 5050
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.falafelapi_log_group.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "ecs"
        "awslogs-create-group"  = "true"
      }
    }
  }])
}

resource "aws_ecs_service" "falafelapi" {
  name            = "falafelapi-service"
  cluster         = aws_ecs_cluster.fargate_cluster.id
  task_definition = aws_ecs_task_definition.falafelapi.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = tolist(data.aws_subnets.private.ids)
    security_groups = [aws_security_group.falafelapi_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.falafel_tg_3000.arn
    container_name   = "falafelapi"
    container_port   = 3000
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.falafel_tg_5050.arn
    container_name   = "falafelapi"
    container_port   = 5050
  }

  depends_on = [
    aws_lb_listener.falafel_listener_3000,
    aws_lb_listener.falafel_listener_5050
  ]

  desired_count = 1

  lifecycle {
    create_before_destroy = true
  }
}


