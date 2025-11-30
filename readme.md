- 2 subnet across 2 availability Zones for high availability
- secret manager 
- kms 
- sns trigger
- cloudwatch logs
- Pre-migration Assessments : export the results to S3. This proves the migration is safe before it starts.
- CloudWatch Alarms
- state locking
- ansible for configuration
- trivy
- argo cd
- github actions
- terraform




.
├── .github/workflows/main.yml    # CI/CD Pipeline
├── ansible/
│   ├── inventory.ini
│   └── seed_db.yml              # Database seeding playbook
├── modules/
│   ├── networking/              # VPC, 2 AZ Subnets
│   ├── security/                # KMS, Secrets, IAM
│   └── dms/                     # DMS Instance, Tasks, Endpoints
├── main.tf                      # Root module
├── variables.tf

└── backend.tf                   # S3 + DynamoDB State Locking


### On‑prem dummy MySQL (EC2) configuration

Set these Terraform variables before running:
- `onprem_mysql_password` — password for `dms_user` (store in CI secrets)
- `admin_cidr` — your admin IP CIDR for SSH
- `onprem_ami_id` — AMI ID for EC2 (Amazon Linux 2)
- `ssh_key_name` — EC2 key pair name
- `assessment_s3_bucket` — S3 bucket for assessment exports
- `onprem_secret_arn` — Secrets Manager ARN created by security module

Run:
1. `terraform init` (bootstrap backend first)
2. `terraform apply -target=module.state` to create backend
3. `terraform apply` to create infra
4. After apply, run Ansible: `ansible-playbook infra/ansible/site.yml -i infra/ansible/inventory.ini`
5. Trigger DMS assessment via CI or run the AWS CLI command shown in the workflow




┌───────────────────────────────────────────┐
│                    GitHub Repository      │
│  ┌──────────────┐  ┌──────────────┐       │
│  │   Terraform  │  │   Ansible    │       │
│  │    Modules   │  │  Playbooks   │       │
│  └──────────────┘  └──────────────┘       │
└───────────────────────────────────────────┘
                            │
                            ▼
                  ┌──────────────────┐
                  │ GitHub Actions   │
                  │    Workflow      │
                  └──────────────────┘
                            │
            ┌───────────────┼───────────────┐
            ▼               ▼               ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │   Trivy      │ │  Terraform   │ │   Ansible    │
    │   Security   │ │    Apply     │ │    Config    │
    │    Scan      │ │              │ │              │
    └──────────────┘ └──────────────┘ └──────────────┘
                            │
                            ▼
                  ┌──────────────────┐
                  │   AWS Account    │
                  │                  │
                  │  ┌────────────┐  │
                  │  │    VPC     │  │
                  │  │  ┌──────┐  │  │
                  │  │  │ EC2  │  │  │
                  │  │  │ RDS  │  │  │
                  │  │  │ DMS  │  │  │
                  │  │  └──────┘  │  │
                  │  └────────────┘  │
                  └──────────────────┘
                            │
                            ▼
                  ┌──────────────────┐
                  │  DMS Monitoring  │
                  │   Application    │
                  └──────────────────┘





                  dms-migration-project/
├── .github/
│   └── workflows/
│       ├── terraform-deploy.yml       # Main deployment workflow
│       ├── security-scan.yml          # Trivy security scanning

├── terraform/                         # Your existing terraform code
│   ├── modules/
│   ├── main.tf
│   └── ...
├── ansible/
│   ├── playbook.yml
│   └── ...
└── scripts/
    ├── create-argocd-secrets.sh
    └── sync-argocd.sh










    GitHub Push
    ↓
GitHub Actions Workflow
    ↓
┌─────────────────────────────────┐
│  1. Security Scan (Trivy)      │
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│  2. Terraform Apply (Infra)     │
│     - VPC, Subnets              │
│     - EC2 (On-prem MySQL)       │
│     - RDS (Target)              │
│     - DMS Instance              │
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│  3. Wait for Services           │
│     - MySQL init (5 min)        │
│     - RDS available (10 min)    │
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│  4. Ansible Configuration       │
│     - Setup MySQL binlog        │
│     - Configure CDC             │
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│  5. Load Data from data.sql     │
│     - Create tables             │
│     - Import data.sql           │
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│  6. DMS Migration               │
│     - Test endpoints            │
│     - Run assessment            │
│     - Start replication         │
└─────────────────────────────────┘
    ↓
┌─────────────────────────────────┐
│  7. Validation                  │
│     - Compare row counts        │
│     - Test CDC                  │
│     - Generate report           │
└─────────────────────────────────┘# dms-migration
