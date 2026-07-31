terraform {
  backend "s3" {
    bucket         = "mlops-security-platform-tfstate-616150220421"
    key            = "project1/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "mlops-security-platform-tf-lock"
    encrypt        = true
  }
}
