provider "aws" {
  region = "us-east-1"
}

# # This replaces the 'curl' command you tried to run
# data "http" "my_ip" {
#   url = "https://checkip.amazonaws.com"
# }

# data "aws_caller_identity" "current" {}

# data "aws_ami" "amazon_linux_2" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }

# module "vpc" {
#   source   = "./modules/vpc"
#   vpc_name = "migration-vpc"
#   vpc_cidr = "10.0.0.0/16"
# }

# module "sg" {
#   source     = "./modules/sg"
#   name      = "dms-replication-sg"
#   vpc_id     = module.vpc.vpc_id
#   admin_cidr = var.admin_cidr
# }


# module "iam" {
#   source = "./modules/iam"
#   name = "dms-iam"

#   # IAM role + instance profile names
#   kms_key_id = module.iam.dms.id
#   iam-profile-name = dms-ec2-profile
#   role               = "dms-role"

#   # Secrets
#   onprem_secret_arn = aws_secretsmanager_secret.onprem_mysql.arn
#   # Or from another module:
#   # onprem_secret_arn = module.secrets.onprem_secret_arn

#   # S3 for assessments
#   assessment_s3_bucket = "dms-audit-${data.aws_caller_identity.current.account_id}"
#   audit_bucket_name    = "dms-audit-${data.aws_caller_identity.current.account_id}"

#   # Passwords
#   onprem_mysql_password = var.onprem_mysql_password

#   # VPC context
#   vpc_id = module.vpc.vpc_id
# }


# module "onprem_mysql" {
#   source                = "./modules/ec2"
#   name                  = "onprem"
#   vpc_id                = module.vpc.vpc_id
#   subnet_id             = module.vpc.public_subnets[0]
#   dms_security_group_id = module.sg.dms_sg_id
#   admin_cidr            = var.admin_cidr
#   ami_id                = var.onprem_ami_id
#   instance_type         = "t3.medium"
#   ssh_key_name          = var.ssh_key_name
# }

# module "rds_target" {
#   source     = "./modules/rds"
#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets
#   sg_id      = module.sg.rds_sg_id
# }

# module "dms" {
#   source = "./modules/dms"
#   name                 = "dms-migration"
#   kms_key_id           = module.iam.kms_key_id
#   assessment_s3_bucket = module.iam.audit_bucket_name

#   subnet_ids                  = module.vpc.private_subnets
#   dms_sg                      = module.sg.dms_sg_id
#   kms_key_arn_dest            = module.iam.kms_key_arn
#   onprem_secret_arn           = module.iam.onprem_secret_arn
#   dest_secret_arn             = module.iam.dest_secret_arn
#   dms_secrets_role_arn        = module.iam.dms_role_arn
#   dms_assessment_iam_role_arn = module.iam.dms_assessment_role_arn
#   audit_bucket_name           = module.iam.audit_bucket_name
#   source_server               = module.onprem_mysql.mysql_private_ip
#   database                    = "production_db"
#   aws_region                  = "us-east-1"

#   depends_on = [module.onprem_mysql, module.rds_target]
# }



# module "terraform_backend" {
#   source = "../modules/terraform-backend"

#   bucket_name          = "terraform-state-dms-${data.aws_caller_identity.current.account_id}"
#   dynamodb_table_name  = "terraform-lock-table"
#   environment          = "prod"
# }

# 1. DATA SOURCES
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# 2. NETWORKING
module "vpc" {
  source   = "./modules/vpc"
  vpc_name = "migration-vpc"
  vpc_cidr = "10.0.0.0/16"
}

module "sg" {
  source = "./modules/sg"
  name   = "dms-replication-sg"
  vpc_id = module.vpc.vpc_id
  # Dynamic IP fetching
  admin_cidr            = var.admin_cidr == "" ? "${chomp(data.http.my_ip.response_body)}/32" : var.admin_cidr
  onprem_mysql_password = var.onprem_mysql_password
}

# 3. IAM & SECRETS (Creates the Keys and Secrets)
module "iam" {
  source               = "./modules/iam"
  name                 = "dms-iam"
  iam-profile-name     = "dms-ec2-profile"
  role                 = "dms-role"
  assessment_s3_bucket = "dms-audit-${data.aws_caller_identity.current.account_id}"
  audit_bucket_name    = "dms-audit-${data.aws_caller_identity.current.account_id}"
  # Passwords
  onprem_mysql_password = var.onprem_mysql_password
  # VPC
  vpc_id = module.vpc.vpc_id
}

# 4. ON-PREM EC2 (Uses resources from VPC, SG, and IAM)
module "onprem_mysql" {
  source                = "./modules/ec2"
  name                  = "onprem"
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.public_subnets[0]
  dms_security_group_id = module.sg.dms_sg_id
  admin_cidr            = var.admin_cidr == "" ? "${chomp(data.http.my_ip.response_body)}/32" : var.admin_cidr

  # Dynamic AMI fetching
  ami_id        = var.onprem_ami_id == "" ? data.aws_ami.amazon_linux_2.id : var.onprem_ami_id
  instance_type = "t3.medium"
  ssh_key_name  = var.ssh_key_name
}

# 5. TARGET RDS
module "rds_target" {
  source          = "./modules/rds"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  sg_id           = module.sg.rds_sg_id
  kms_key_id      = module.iam.kms_key_id
  master_password = var.onprem_mysql_password
}

# 6. DMS INSTANCE & TASKS (The Consumer)
module "dms" {
  source = "./modules/dms"
  name   = "dms-migration"
  replication_instance_class = var.replication_instance_class
  allocated_storage          = var.allocated_storage
  engine_version             = var.engine_version

  # Pass outputs FROM the iam module
  kms_key_id                  = module.iam.kms_key_id
  kms_key_arn_dest            = module.iam.kms_key_arn
  onprem_secret_arn           = module.iam.onprem_secret_arn
  dest_secret_arn             = module.iam.dest_secret_arn
  dms_secrets_role_arn        = module.iam.dms_role_arn
  dms_assessment_iam_role_arn = module.iam.dms_assessment_role_arn
  alert_email                 = var.alert_email
  # Buckets
  assessment_s3_bucket = module.iam.audit_bucket_name
  audit_bucket_name    = module.iam.audit_bucket_name

  # Network & Source
  subnet_ids    = module.vpc.private_subnets
  dms_sg        = module.sg.dms_sg_id
  source_server = module.onprem_mysql.mysql_private_ip
  database      = "production_db"
  aws_region    = "us-east-1"

  depends_on = [module.onprem_mysql, module.rds_target]
}

# 7. BACKEND (Optional, keep if you have the bucket)
module "terraform_backend" {
  source = "./modules/backend"

  bucket_name         = "terraform-state-dms-${data.aws_caller_identity.current.account_id}"
  dynamodb_table_name = "terraform-lock-table"
  environment         = "prod"
  kms_key_arn         = module.iam.kms_key_arn
}

