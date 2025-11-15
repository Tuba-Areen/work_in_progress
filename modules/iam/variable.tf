variable "iam-profile-name" {}

variable "role" {}

variable "assessment_s3_bucket" {}

variable "name" {}

variable "audit_bucket_name" {
  type        = string
  description = "S3 bucket name for DMS assessments"
}

variable "onprem_mysql_password" {
  type        = string
  sensitive   = true
  description = "Password for on-prem MySQL"
}

variable "dest_rds_password" {
  type        = string
  sensitive   = true
  description = "Password for destination RDS"
  default     = "admin123!"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID (for tagging purposes)"
}