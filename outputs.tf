
output "onprem_mysql_public_ip" {
  value = module.onprem_mysql.mysql_public_ip
}

output "onprem_mysql_private_ip" {
  value = module.onprem_mysql.mysql_private_ip
}

output "rds_endpoint" {
  value = module.rds_target.rds_endpoint
}

output "dms_replication_task_arn" {
  value = module.dms.dms_replication_task_arn
}

output "dms_assessment_role_arn" {
  value = module.iam.dms_assessment_role_arn
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "onprem_secret_arn" {
  value = module.iam.onprem_secret_arn
}
