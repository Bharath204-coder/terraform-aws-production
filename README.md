# 🏗️ Production-Grade AWS Infrastructure — Terraform IaC

![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![MySQL](https://img.shields.io/badge/mysql-%2300f.svg?style=for-the-badge&logo=mysql&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

A fully automated, production-grade AWS infrastructure built with Terraform Infrastructure as Code (IaC). This project provisions a scalable, secure, and highly available web application environment across multiple Availability Zones — the same architecture pattern used by real companies in production.

---

## 📐 Architecture


### Infrastructure Overview

<img width="1536" height="1024" alt="AWS_Architecture" src="https://github.com/user-attachments/assets/6786737f-f6a4-4484-8e7c-6cf885aa53cf" />


## ✅ Infrastructure Components

| Component | Service | Details |
|---|---|---|
| Network | AWS VPC | 10.0.0.0/16 · Multi-AZ · Custom routing |
| Load Balancer | ALB | Internet-facing · Port 80/443 · Health checks |
| Compute | EC2 + ASG | Amazon Linux 2 · t2.micro · min 2, max 5 |
| Database | RDS MySQL | MySQL 8.0 · db.t3.micro · Private subnet |
| Security | Security Groups | 3-tier chaining: ALB → EC2 → RDS |
| IAM | Instance Profile | CloudWatch Agent + SSM policies |
| Monitoring | CloudWatch | CPU alarms · Log groups · Metrics |
| State | S3 + DynamoDB | Remote state · Versioning · Lock table |

---

## 📁 Project Structure

```
terraform-aws-production/
│
├── backend/                        # Phase 1 — Remote state bootstrap (run once)
│   └── main.tf                     # S3 bucket + DynamoDB lock table
│
├── modules/
│   ├── vpc/                        # Phase 2 — Network layer
│   │   ├── main.tf                 # VPC, subnets, IGW, NAT, route tables
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── security-groups/            # Phase 3 — Firewall rules
│   │   ├── main.tf                 # ALB-SG, EC2-SG, RDS-SG (chained)
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── alb/                        # Phase 4 — Load balancer
│   │   ├── main.tf                 # ALB, target group, listener
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── asg/                        # Phase 5 — Auto scaling
│   │   ├── main.tf                 # Launch template + ASG
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── rds/                        # Phase 6 — Database
│   │   ├── main.tf                 # RDS MySQL + subnet group
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── iam/                        # Phase 7 — Access control
│   │   ├── main.tf                 # IAM role + instance profile
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── cloudwatch/                 # Phase 7 — Monitoring
│       ├── main.tf                 # CPU alarms + log groups
│       ├── variables.tf
│       └── outputs.tf
│
├── main.tf                         # Root module — wires all modules together
├── variables.tf                    # Root variable declarations
├── outputs.tf                      # ALB DNS name + RDS endpoint
├── versions.tf                     # Provider versions + S3 backend config
├── terraform.tfvars                # Environment values (do not commit secrets)
└── README.md
```

---

## 🔒 Security Design

This infrastructure follows a **defence-in-depth** security model:

```
Internet → ALB-SG (port 80/443 from 0.0.0.0/0)
                │
                ▼
           EC2-SG (port 8080 from ALB-SG only)
                │
                ▼
           RDS-SG (port 3306 from EC2-SG only)
```

- EC2 instances have **no public IP** — only reachable through the ALB
- RDS is in a **private subnet** — never publicly accessible
- IAM follows **least privilege** — EC2 only has CloudWatch + SSM permissions
- S3 state bucket has **encryption + public access blocked**

---

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed and configured:

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with valid credentials
- An AWS account with sufficient IAM permissions

Verify your setup:

```bash
terraform --version
aws --version
aws sts get-caller-identity
```

---

## 🚀 Getting Started

### Step 1 — Clone the repository

```bash
git clone https://github.com/Bharath204-coder/terraform-aws-production.git
cd terraform-aws-production
```

### Step 2 — Bootstrap remote state (run once only)

```bash
cd backend
terraform init
terraform apply
cd ..
```

This creates the S3 bucket and DynamoDB table for remote state management.

### Step 3 — Update backend configuration

In `versions.tf`, update the backend block with your S3 bucket name:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket-name"
  key            = "production/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "terraform-state-locks"
  encrypt        = true
}
```

### Step 4 — Update variables

Edit `terraform.tfvars` with your values:

```hcl
project_name         = "your-project-name"
environment          = "production"
aws_region           = "us-east-1"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]
db_name              = "yourdb"
db_username          = "admin"
db_password          = "YourSecurePassword123!"
```

> ⚠️ Never commit `terraform.tfvars` with real passwords to version control.

### Step 5 — Deploy the infrastructure

```bash
terraform init
terraform plan
terraform apply
```

---

## 📋 Terraform Commands Reference

| Command | Description |
|---|---|
| `terraform init` | Initialize providers and backend |
| `terraform plan` | Preview changes before applying |
| `terraform apply` | Deploy infrastructure to AWS |
| `terraform destroy` | Tear down all resources |
| `terraform state list` | List all managed resources |
| `terraform output` | Show output values (ALB URL, RDS endpoint) |
| `terraform fmt` | Format code to standard style |
| `terraform validate` | Validate configuration syntax |

---

## 📤 Outputs

After successful `terraform apply`:

```bash
alb_dns_name = "your-project-alb-xxxxxxxxx.us-east-1.elb.amazonaws.com"
rds_endpoint = "your-project-db.xxxxxxxxx.us-east-1.rds.amazonaws.com:3306"
```

Open the ALB DNS name in your browser to verify the application is running.

---

## 🧠 What I Learned

Building this project gave me hands-on experience with:

- **Terraform modules** — structuring reusable, maintainable IaC with input/output variables
- **Remote state management** — S3 backend with DynamoDB locking for team collaboration
- **VPC networking** — subnets, route tables, IGW, NAT Gateway, and CIDR design
- **Security group chaining** — defence-in-depth by restricting traffic layer by layer
- **Auto Scaling** — Launch Templates, health checks, and dynamic scaling policies
- **RDS in production** — subnet groups, encryption, and Multi-AZ failover concepts
- **IAM best practices** — instance profiles, trust policies, and least-privilege access
- **CloudWatch** — metric alarms and log groups for infrastructure observability

---

## 📌 Future Improvements

- [ ] Add HTTPS with ACM certificate on ALB
- [ ] Enable RDS Multi-AZ (`multi_az = true`)
- [ ] Add Secrets Manager for RDS credentials
- [ ] Implement CloudWatch dashboards
- [ ] Add GitHub Actions CI/CD pipeline for automated `terraform plan`
- [ ] Enable VPC Flow Logs for network auditing
- [ ] Add WAF to ALB for DDoS protection

---

## 👤 Author

**Bharath C M**
- GitHub: [@Bharath204-coder](https://github.com/Bharath204-coder)
- Email: bharathcm204@gmail.com
- Certification: AWS Certified Cloud Practitioner

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
