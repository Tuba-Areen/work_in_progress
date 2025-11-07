variable "name" {
  type        = string
  description = "Name prefix for resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for EC2 instance"
}
variable "dms_security_group_id" {
  type        = string
  description = "Security Group ID for DMS replication instance"
}

variable "admin_cidr" {
  type        = string
  description = "Admin IP CIDR for SSH access"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 MySQL instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 Instance Type"
  default     = "c7i-flex.large"  # Cost-effective choice for MySQL workloads
}

variable "ssh_key_name" {
  type        = string
  description = "EC2 Key Pair name"
}

