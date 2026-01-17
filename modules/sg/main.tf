# Security Group for On-Prem EC2 MySQL
resource "aws_security_group" "onprem" {
  name        = "onprem-mysql-sg"
  description = "Security group for on-prem MySQL EC2"
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
    security_groups = [aws_security_group.dms.id]
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
    Name = "onprem-mysql-sg"
  }
}

# Security Group for DMS Replication Instance
resource "aws_security_group" "dms" {
  name        = "dms-replication-sg"
  description = "Security group for DMS replication instance"
  vpc_id      = var.vpc_id

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
    Name = "dms-replication-sg"
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "rds-target-sg"
  description = "Security group for RDS target database"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from DMS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.dms.id]
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
    Name = "rds-target-sg"
  }
}