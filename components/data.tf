data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["private*"]
  }
}


data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["public*"]
  }
}

data "aws_ecr_repository" "falafel_ecr" {
  name       = "falafelapp"
  depends_on = [aws_ecr_repository.falafel]
}
