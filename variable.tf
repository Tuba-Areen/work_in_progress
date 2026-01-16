variable "onprem_mysql_password" {
  type        = string
  sensitive   = true
  description = "Password for on-prem MySQL DMS user"
}

variable "ssh_key_name" {
  type        = string
  description = "EC2 Key Pair name"
}

variable "alert_email" {
  type        = string
  description = "Email for DMS notifications"
}

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key for CI/CD"
  sensitive   = true
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key for CI/CD"
  sensitive   = true
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