resource "aws_ecr_repository" "falafel" {
  name                 = "falafelapp"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}