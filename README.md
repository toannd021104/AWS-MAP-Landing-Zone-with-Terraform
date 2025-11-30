# AWS MAP Landing Zone

AWS Migration Acceleration Program (MAP) Landing Zone using Terraform.

Based on [AWS Whitepaper: Building Scalable and Secure Multi-VPC Network Infrastructure](https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure/welcome.html)

## Features

- **Networking**: VPC, Transit Gateway (Hub-and-Spoke), VPC Endpoints (PrivateLink), Network Firewall
- **Security**: GuardDuty, Security Hub, AWS Config, CloudTrail, KMS
- **Organizations**: OUs, Service Control Policies (SCPs), Account Factory
- **IAM**: Pre-configured roles with least privilege

## Prerequisites

- Terraform >= 1.10.0 (for S3 native state locking)
- AWS CLI v2
- AWS Account with appropriate permissions
- jq (for scripts)

## Quick Start

```bash
# 1. Clone and navigate to project
git clone https://github.com/YOUR_USERNAME/aws-map-landing-zone.git
cd aws-map-landing-zone

# 2. Configure backend (IMPORTANT!)
cp backend.tf.example backend.tf
# Edit backend.tf with your S3 bucket name and AWS region

# 3. Make scripts executable
chmod +x scripts/*.sh

# 4. Setup S3 backend bucket
./scripts/setup-backend.sh

# 5. Initialize Terraform
./scripts/init.sh dev init

# 6. Plan deployment
./scripts/init.sh dev plan

# 7. Apply configuration
./scripts/init.sh dev apply
```

## Project Structure

```
aws-map-landing-zone/
├── main.tf                 # Main configuration
├── variables.tf            # Global variables
├── outputs.tf              # Output definitions
├── providers.tf            # Provider configuration
├── versions.tf             # Version constraints
├── backend.tf              # Backend configuration
├── modules/
│   ├── networking/         # VPC, Subnets, NAT, etc.
│   ├── security/           # GuardDuty, Security Hub, Config
│   ├── logging/            # CloudTrail, CloudWatch, S3
│   ├── iam/                # Roles, Policies, Groups
│   ├── compute/            # EC2, ECS (placeholder)
│   └── organizations/      # AWS Organizations (placeholder)
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── scripts/
│   ├── init.sh             # Initialization script
│   ├── setup-backend.sh    # S3 backend setup
│   └── validate.sh         # Validation script
└── docs/
    └── ARCHITECTURE.md     # Architecture documentation
```

## Modules

### Networking
- VPC with multi-AZ support
- Public, Private, and Database subnets
- NAT Gateway (single or HA)
- Transit Gateway (Hub-and-Spoke topology)
- VPC Endpoints (PrivateLink) - S3, DynamoDB, SSM, EC2, CloudWatch, ECR, KMS, STS
- Network Firewall with stateful/stateless rules
- VPC Flow Logs
- Route 53 Private Hosted Zone (optional)

### Security
- AWS GuardDuty
- AWS Security Hub
- AWS Config
- KMS Keys for encryption
- Security Groups (ALB, App, Database, Bastion)

### Logging
- AWS CloudTrail
- CloudWatch Log Groups
- S3 bucket for centralized logs
- SNS Topics for alerts
- CloudWatch Alarms

### IAM
- Admin, Developer, ReadOnly roles
- CI/CD role for pipelines
- EC2 Instance Profile
- Lambda Execution Role
- ECS Task Execution Role
- IAM Groups with MFA policies

### Organizations (Control Tower Style)
- Organization Units: Security, Infrastructure, Workloads, Sandbox
- Nested OUs: Production, Non-Production under Workloads
- Service Control Policies (SCPs):
  - DenyLeaveOrganization
  - DenyRootUser
  - RequireIMDSv2
  - ProtectSecurityServices
  - RestrictRegions
- Account Factory for automated account creation

## Environments

| Environment | VPC CIDR | NAT Gateway | VPN |
|-------------|----------|-------------|-----|
| dev | 10.0.0.0/16 | Single | No |
| staging | 10.1.0.0/16 | Single | No |
| prod | 10.2.0.0/16 | Multi-AZ | Yes |

## Usage

### Deploy to specific environment
```bash
# Development
./scripts/init.sh dev apply

# Staging
./scripts/init.sh staging apply

# Production (with confirmation)
./scripts/init.sh prod apply
```

### Validate configuration
```bash
./scripts/validate.sh
```

### Destroy environment
```bash
./scripts/init.sh dev destroy
```

## Security Features

- All data encrypted at rest using KMS
- TLS/HTTPS enforced
- MFA required for admin roles
- CIS Benchmarks enabled
- Comprehensive audit logging
- Real-time threat detection

## Cost Optimization

- Single NAT Gateway for dev/staging
- S3 lifecycle policies for log archival
- S3 native state locking (no DynamoDB required)
- Modular design for selective deployment

## Contributing

1. Create a feature branch
2. Run `terraform fmt -recursive`
3. Run `./scripts/validate.sh`
4. Submit pull request

## License

MIT License
