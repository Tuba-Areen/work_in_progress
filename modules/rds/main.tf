resource "aws_db_subnet_group" "main" {
  name       = "dms-target-subnet-group"
  subnet_ids = var.subnet_ids
  tags = { Name = "DMS Target Subnet Group" }
}

resource "aws_db_instance" "target" {
  identifier             = "dms-target-rds"
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp3"
  db_name                = "production_db"
  username               = "admin"
  password               = var.master_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.sg_id]
  multi_az               = true
  backup_retention_period = 7
  skip_final_snapshot    = true
  publicly_accessible    = false
  storage_encrypted      = true
  kms_key_id             = var.kms_key_id

  tags = { Name = "DMS Target RDS" }
}
