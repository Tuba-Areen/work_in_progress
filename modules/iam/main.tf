# KMS Key for Encryption
resource "aws_kms_key" "dms" {
  description             = "KMS key for DMS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "dms-encryption-key"
  }
}

resource "aws_kms_alias" "dms" {
  name          = "alias/dms-migration"
  target_key_id = aws_kms_key.dms.key_id
}

# S3 Bucket for Assessments
resource "aws_s3_bucket" "audit" {
  bucket = var.audit_bucket_name

  tags = {
    Name = "DMS Migration Audit Bucket"
  }
}

resource "aws_s3_bucket_versioning" "audit" {
  bucket = aws_s3_bucket.audit.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit" {
  bucket = aws_s3_bucket.audit.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.dms.arn
    }
  }
}

# Secrets Manager - On-Prem MySQL Credentials
resource "aws_secretsmanager_secret" "onprem_mysql" {
  name       = "dms-onprem-mysql-creds"
  kms_key_id = aws_kms_key.dms.id

  tags = {
    Name = "On-Prem MySQL Credentials"
  }
}

resource "aws_secretsmanager_secret_version" "onprem_mysql" {
  secret_id = aws_secretsmanager_secret.onprem_mysql.id
  secret_string = jsonencode({
    username = "dms_user"
    password = var.onprem_mysql_password
  })
}

# Secrets Manager - Target RDS Credentials
resource "aws_secretsmanager_secret" "dest_rds" {
  name       = "dms-dest-rds-creds"
  kms_key_id = aws_kms_key.dms.id

  tags = {
    Name = "Destination RDS Credentials"
  }
}

resource "aws_secretsmanager_secret_version" "dest_rds" {
  secret_id = aws_secretsmanager_secret.dest_rds.id
  secret_string = jsonencode({
    username = "admin"
    password = var.dest_rds_password
  })
}

# IAM Role for DMS Assessment
resource "aws_iam_role" "dms_assessment" {
  name = "dms-assessment-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "dms.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "DMS Assessment Role"
  }
}

resource "aws_iam_role_policy" "dms_assessment_s3" {
  name = "dms-assessment-s3-policy"
  role = aws_iam_role.dms_assessment.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.audit.arn,
          "${aws_s3_bucket.audit.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [aws_kms_key.dms.arn]
      }
    ]
  })
}

# IAM Role for DMS to access Secrets Manager
resource "aws_iam_role" "dms_secrets" {
  name = "dms-secrets-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "dms.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "DMS Secrets Access Role"
  }
}

resource "aws_iam_role_policy" "dms_secrets_policy" {
  name = "dms-secrets-policy"
  role = aws_iam_role.dms_secrets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.onprem_mysql.arn,
          aws_secretsmanager_secret.dest_rds.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [aws_kms_key.dms.arn]
      }
    ]
  })
}

# DMS VPC Management Role (Required by AWS DMS)
resource "aws_iam_role" "dms_vpc" {
  name = "dms-vpc-management-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "dms.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "DMS VPC Management Role"
  }
}

resource "aws_iam_role_policy_attachment" "dms_vpc_policy" {
  role       = aws_iam_role.dms_vpc.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"
}

# DMS CloudWatch Logs Role
resource "aws_iam_role" "dms_cloudwatch" {
  name = "dms-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "dms.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "DMS CloudWatch Logs Role"
  }
}

resource "aws_iam_role_policy_attachment" "dms_cloudwatch_policy" {
  role       = aws_iam_role.dms_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"
}