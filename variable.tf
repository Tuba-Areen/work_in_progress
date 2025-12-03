variable "onprem_mysql_password" {
  type        = string
  sensitive   = true
  description = "Password for on-prem MySQL DMS user"
}

variable "admin_cidr" {
  type        = string
  description = "Admin IP CIDR for SSH access"
}

variable "onprem_ami_id" {
  type        = string
  description = "AMI ID for EC2 MySQL instance"
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
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key"
}