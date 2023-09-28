
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.17.0"
    }
  }
  required_version = " >= 1.0"



  backend "s3" {
    bucket = "us-east-1-test-buckets-29-09-2023"
    key    = "prod/terraform.state"
    region = "us-east-1"
  }
}
