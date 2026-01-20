
output "onprem_sg_id" {
  value = aws_security_group.onprem.id
}

output "dms_sg_id" {
  value = aws_security_group.dms.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}