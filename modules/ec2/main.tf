resource "aws_security_group" "mysql" {
  name        = "${var.name}-mysql-sg"
  description = "Security group for on-prem MySQL"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description     = "MySQL from DMS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.dms_security_group_id]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-mysql-sg"
  }
}

resource "aws_instance" "mysql" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.mysql.id]
  key_name               = var.ssh_key_name
  user_data              = templatefile("${path.module}/userdata/mysql_install.sh",{
    AWS_REGION = "us-east-1"
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }

  associate_public_ip_address = true
  tags = {
    Name = "${var.name}-mysql"
  }
}

resource "aws_eip" "mysql" {
  instance = aws_instance.mysql.id
  domain   = "vpc"

  tags = {
    Name = "${var.name}-mysql-eip"
  }

  depends_on = [aws_instance.mysql]
}