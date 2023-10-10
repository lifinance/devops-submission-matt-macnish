terraform {
  backend "s3" {
    bucket  = "backend-bucket-04102024"
    key     = "state"
    region  = "eu-central-1"
    encrypt = true
  }
}
