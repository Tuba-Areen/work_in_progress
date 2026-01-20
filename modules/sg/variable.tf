variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "onprem_mysql_password" {
  type      = string
  sensitive = true
}

variable "dest_mysql_password" {
  type      = string
  sensitive = true
  default   = "admin123!"
}

variable "ports" {
  type = map(string)
  default = {
    3306 = "10.0.0.0/16" # FIXED: Valid CIDR
  }
}

variable "admin_cidr" {
  type        = string
  description = "Admin IP CIDR for SSH"
  default     = "0.0.0.0/0" # Override in production
}