terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # This ensures you are on a version that supports these resources
    }
  }
}

provider "aws" {
  region = "us-east-1"
}