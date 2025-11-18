
output "dms_security_group_id" {
  value = var.dms_sg
}

output "dms_replication_task_arn" {
  value = aws_dms_replication_task.main.replication_task_arn
}

output "dms_replication_instance_arn" {
  value = aws_dms_replication_instance.main.replication_instance_arn
}

output "dms_source_endpoint_arn" {
  value = aws_dms_endpoint.source.endpoint_arn
}

output "dms_target_endpoint_arn" {
  value = aws_dms_endpoint.target.endpoint_arn
}
