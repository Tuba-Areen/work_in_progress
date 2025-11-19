resource "null_resource" "run_assessment" {
  provisioner "local-exec" {
    command = <<EOT
  aws dms start-replication-task-assessment-run \
  --replication-task-arn ${aws_dms_replication_task.main.replication_task_arn} \
  --s3-bucket-name ${var.assessment_s3_bucket} \
  --s3-prefix assessments/${var.name}/run-${timestamp()} \
  --region ${var.aws_region}
EOT
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    task_arn = aws_dms_replication_task.main.replication_task_arn
  }
}
