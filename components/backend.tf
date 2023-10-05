terraform {
  backend "s3" {
    bucket  = "backend-bucket-04102023"
    key     = "state"
    region  = "eu-west-1"
    encrypt = true
  }
}