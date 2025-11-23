variable "bucket_name" {
    description = "Name of the S3 bucket for Terraform remote state"
    type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
}