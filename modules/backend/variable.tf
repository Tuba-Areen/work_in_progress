variable "kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for S3 bucket encryption"
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket"
}

variable "dynamodb_table_name" {
  type        = string
  description = "The name of the DynamoDB table"
}

variable "environment" {
  type        = string
  description = "The environment"
}
