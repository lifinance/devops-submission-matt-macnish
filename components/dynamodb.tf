resource "aws_dynamodb_table" "falafelreviews" {
  name         = "FalafelReviews"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "falafel_restaurant"
    type = "S"
  }

  hash_key = "falafel_restaurant"

  lifecycle {
    create_before_destroy = true
  }
}
