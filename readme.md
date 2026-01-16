# AWS Database Migration Service (DMS) Migration Project

This project provides a comprehensive, automated solution for migrating a MySQL database to AWS using the Database Migration Service (DMS). The entire infrastructure is managed as code using Terraform, with configuration and database seeding handled by Ansible.

## Key Features

*   **Automated Infrastructure:** The entire infrastructure is deployed and managed using Terraform, ensuring consistency and repeatability.
*   **CI/CD Pipeline:** A complete CI/CD pipeline is provided using GitHub Actions, which automates security scanning, infrastructure deployment, configuration, and the DMS migration process.
*   **High Availability:** The architecture is designed for high availability, with subnets across two availability zones.
*   **Secure by Design:** The project leverages AWS Key Management Service (KMS) for encryption and AWS Secrets Manager for securely storing database credentials.
*   **Pre-Migration Assessments:** The CI/CD pipeline includes a step to run a pre-migration assessment, which exports the results to an S3 bucket. This helps ensure the migration is safe before it begins.
*   **Monitoring and Alerting:** The project includes CloudWatch Alarms and SNS triggers to send email notifications for important DMS events.

## Architecture Overview

The following diagram provides a high-level overview of the project's architecture:

```
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
```

## Getting Started

### Prerequisites

*   An AWS account with the necessary permissions to create the resources defined in this project.
*   An AWS EC2 key pair.
*   [Terraform](https://www.terraform.io/downloads.html) (version 1.6.0) installed on your local machine.
*   [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) installed on your local machine.
*   An email address for DMS notifications.

### Deployment

1.  **Clone the Repository:**

    ```bash
    git clone <repository-url>
    cd dms-migration-project
    ```

2.  **Configure Your Variables:**

    Create a `terraform.tfvars` file in the root of the project with the following content:

    ```terraform
    onprem_mysql_password = "your-mysql-password"
    ssh_key_name          = "your-ec2-key-pair-name"
    alert_email           = "your-email@example.com"
    ```

3.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

4.  **Deploy the Infrastructure:**

    ```bash
    terraform apply
    ```

    This will provision all the necessary AWS resources.

5.  **Run the Ansible Playbook:**

    After the `terraform apply` is complete, the public IP address of the on-prem MySQL instance will be displayed as an output. You can then run the Ansible playbook to configure the instance:

    ```bash
    ansible-playbook -i <onprem_mysql_public_ip>, ansible/playbook.yml
    ```

### Tearing Down the Infrastructure

To destroy all the resources created by this project, run the following command:

```bash
terraform destroy
```

## CI/CD Pipeline

The project includes a complete CI/CD pipeline using GitHub Actions, which is defined in `.github/workflows/main.yml`. The pipeline automates the following steps:

1.  **Security Scan:** A Trivy scan is run to check for vulnerabilities in the Terraform configuration.
2.  **Terraform Apply:** The Terraform configuration is applied to create or update the infrastructure.
3.  **Ansible Configuration:** The Ansible playbook is run to configure the on-prem MySQL instance.
4.  **DMS Pre-Migration Assessment:** A pre-migration assessment is run to ensure the migration is safe.
5.  **DMS Migration:** The DMS replication task is started to begin the migration.

## Project Structure

```
.
├── .github/workflows/main.yml    # CI/CD Pipeline
├── ansible/
│   ├── inventory.aws_ec2.yml    # Dynamic inventory for Ansible
│   ├── playbook.yml             # Main Ansible playbook
│   └── seed_db.yml              # Database seeding playbook
├── modules/
│   ├── networking/              # VPC, 2 AZ Subnets
│   ├── security/                # KMS, Secrets, IAM
│   └── dms/                     # DMS Instance, Tasks, Endpoints
├── main.tf                      # Root module
├── variables.tf                 # Variable definitions
└── backend.tf                   # S3 + DynamoDB State Locking
```
