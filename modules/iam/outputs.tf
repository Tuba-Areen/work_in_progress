output "kms_key_arn" {
  value = aws_kms_key.dms.arn
}

output "kms_key_id" {
  value = aws_kms_key.dms.key_id
}

output "onprem_secret_arn" {
  value = aws_secretsmanager_secret.onprem_mysql.arn
}

output "dest_secret_arn" {
  value = aws_secretsmanager_secret.dest_rds.arn
}

output "dms_assessment_role_arn" {
  value = aws_iam_role.dms_assessment.arn
}

output "dms_role_arn" {
  value = aws_iam_role.dms_secrets.arn
}

output "audit_bucket_name" {
  value = aws_s3_bucket.audit.id
}

# output "kms_key_id" {
#     value = aws_kms_key.dms.key_id
# }

# output "kms_key_arn" {
#     value = aws_kms_key.dms.arn
# }