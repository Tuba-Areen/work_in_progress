
variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "sg_id" {
  type = string
}

variable "master_password" {
  type      = string
  sensitive = true
  default   = "ChangeMe123!"
}
