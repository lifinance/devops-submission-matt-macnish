resource "aws_iam_role" "api_ecs_role" {
  name = "api-ecs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "api_task_policy" {
  name        = "api-task-policy"
  description = "allow access to add entries to dynamodb"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
      ],
      Resource = "*"
      Effect   = "Allow",
    }]
  })
}

resource "aws_iam_policy" "ecs_logging" {
  name        = "ECSLogging"
  description = "Permissions for ECS to send logs to CloudWatch."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_ecr_pull" {
  name        = "ECSECRAccess"
  description = "Permissions for ECS tasks to pull images from ECR."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
        ],
        Resource = "*"
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_ecr_pull_attachment" {
  policy_arn = aws_iam_policy.ecs_ecr_pull.arn
  role       = aws_iam_role.api_ecs_role.name
}


resource "aws_iam_role_policy_attachment" "api_task_attach" {
  policy_arn = aws_iam_policy.api_task_policy.arn
  role       = aws_iam_role.api_ecs_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_task_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.api_ecs_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_logging_attachment" {
  policy_arn = aws_iam_policy.ecs_logging.arn
  role       = aws_iam_role.api_ecs_role.name
}