resource "aws_dms_replication_subnet_group" "main" {
  replication_subnet_group_id          = "dms-subnet-group"
  replication_subnet_group_description = "DMS Subnet Group"
  subnet_ids                           = var.subnet_ids
}

resource "aws_dms_replication_instance" "main" {
  replication_instance_id      = "dms-replication-instance"
  replication_instance_class   = var.replication_instance_class
  allocated_storage            = var.allocated_storage
  multi_az                     = true
  engine_version               = var.engine_version
  publicly_accessible          = false
  kms_key_arn                  = var.kms_key_arn_dest
  replication_subnet_group_id  = aws_dms_replication_subnet_group.main.id
  vpc_security_group_ids       = [var.dms_sg]
}

data "aws_secretsmanager_secret_version" "onprem" {
  secret_id = var.onprem_secret_arn
}

locals {
  onprem_creds = jsondecode(data.aws_secretsmanager_secret_version.onprem.secret_string)
}

resource "aws_dms_endpoint" "source" {
  endpoint_id   = "source-endpoint"
  endpoint_type = "source"
  engine_name   = "mysql"
  username      = local.onprem_creds.username
  password      = local.onprem_creds.password
  server_name   = var.source_server
  port          = 3306
  database_name = var.database
}

resource "aws_dms_endpoint" "target" {
  endpoint_id                         = "target-endpoint"
  endpoint_type                       = "target"
  engine_name                         = "mysql"
  secrets_manager_arn                 = var.dest_secret_arn
  secrets_manager_access_role_arn     = var.dms_secrets_role_arn
  kms_key_arn                         = var.kms_key_arn_dest
}

resource "aws_dms_replication_task" "main" {
  replication_task_id      = "mysql-migration-task"
  migration_type           = "full-load-and-cdc"
  replication_instance_arn = aws_dms_replication_instance.main.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target.endpoint_arn
  table_mappings           = file("${path.module}/configs/table_mappings.json")
  tags = { Name = "MySQL Migration Task" }
}

# The aws_dms_replication_task_individual_assessment resource was removed from this file.
# Pre-migration assessments are run imperatively via the AWS CLI in the CI/CD pipeline,
# rather than declaratively in Terraform. This is because assessments are one-time
# operations, and managing them with Terraform can lead to state drift.



resource "aws_sns_topic" "dms_alerts" {
  name              = "dms-migration-alerts"
  kms_master_key_id = var.kms_key_id
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.dms_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email 
}

resource "aws_dms_event_subscription" "dms_events" {
  name             = "dms-task-events"
  enabled          = true
  event_categories = ["failure", "state-change", "creation", "deletion"]
  source_type      = "replication-task"
  
  sns_topic_arn    = aws_sns_topic.dms_alerts.arn
  
  # FIXED: Changed 'migration' to 'main' to match the resource name above
  source_ids       = [aws_dms_replication_task.main.replication_task_id]

  tags = {
    Name = "dms-event-subscription"
  }
}