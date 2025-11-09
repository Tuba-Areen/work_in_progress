output "rds_endpoint" {
  value = aws_db_instance.target.endpoint
}

output "rds_arn" {
  value = aws_db_instance.target.arn
}
