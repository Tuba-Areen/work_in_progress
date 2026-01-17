variable "kms_key_id" {
  type        = string
  description = "The KMS key ID to use for storage encryption"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to create the RDS instance in"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to create the RDS instance in"
}

variable "sg_id" {
  type        = string
  description = "The security group ID to associate with the RDS instance"
}

variable "master_password" {
  type        = string
  description = "The password for the master database user"
  sensitive   = true
}
