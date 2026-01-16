variable "subnet_ids" {
  type = list(string)
}

variable "dms_sg" {
  type = string
}

variable "kms_key_arn_dest" {
  type = string
}

variable "kms_key_id" {
  type = string
}

variable "onprem_secret_arn" {
  type = string
}

variable "dest_secret_arn" {
  type = string
}

variable "dms_secrets_role_arn" {
  type = string
}

variable "dms_assessment_iam_role_arn" {
  type = string
}

variable "audit_bucket_name" {
  type = string
}

variable "assessment_s3_bucket" {
  type = string
}

variable "source_server" {
  type = string
}

variable "database" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "name" {}


variable "alert_email" {
  type        = string
  description = "Email address to receive DMS alerts"
}

variable "replication_instance_class" {
  type        = string
  description = "The compute and memory capacity of the replication instance"
  default     = "dms.t3.medium"
}

variable "allocated_storage" {
  type        = number
  description = "The amount of storage (in gigabytes) to be initially allocated for the replication instance"
  default     = 20
}

variable "engine_version" {
  type        = string
  description = "The engine version number of the replication instance"
  default     = "3.5.4"
}
