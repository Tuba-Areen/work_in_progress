terraform {
  backend "s3" {
    bucket         = "terraform-state-dms-dev-793934355667"
    key            = "dms/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-dms-dev"
    encrypt        = true
  }
}
