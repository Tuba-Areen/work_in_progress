
# output "kms_key_arn" {
#     value = aws_kms_key.arn
# }

# output "kms_key_id" {
#     value = aws_kms_key.cmk.key_id
# }

# output "onprem_secret_arn" {
#     value = aws_secretsmanager_secret.onprem_mysql.arn
# }

# output "dest_secret_arn" {
#     value = aws_secretsmanager_secret.dest_rds.arn
# }

output "onprem_sg_id" {
  value = aws_security_group.onprem.id
}

output "dms_sg_id" {
  value = aws_security_group.dms.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}