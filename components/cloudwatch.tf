resource "aws_cloudwatch_log_group" "falafelapi_log_group" {
  name              = "/ecs/falafelapi"
  retention_in_days = 1
}