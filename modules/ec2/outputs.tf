output "mysql_private_ip" {
  value = aws_instance.mysql.private_ip
}

output "mysql_public_ip" {
  value = aws_eip.mysql.public_ip
}

output "mysql_sg_id" {
  value = aws_security_group.mysql.id
}
