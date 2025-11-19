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

