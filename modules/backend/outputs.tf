output "bucket_name" {
  value       = aws_s3_bucket.backend_s3.bucket
  description = "Terraform state bucket name"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "DynamoDB lock table name"
}
