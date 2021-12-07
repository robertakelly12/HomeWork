terraform {
    backend "s3" {
      bucket = "assign-buctaf"
  key = "global/s3/terraform.tfstate"
  region = "us-east-1"
    }
}