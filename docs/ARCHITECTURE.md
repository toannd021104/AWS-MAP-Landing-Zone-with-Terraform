# AWS MAP Landing Zone - Architecture

## Overview

This Landing Zone follows AWS best practices for the Migration Acceleration Program (MAP) and implements a secure, scalable, and compliant cloud infrastructure.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWS Account                                     │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                         VPC (10.x.0.0/16)                              │  │
│  │  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐          │  │
│  │  │  Public Subnet  │ │  Public Subnet  │ │  Public Subnet  │          │  │
│  │  │    AZ-1a        │ │    AZ-1b        │ │    AZ-1c        │          │  │
│  │  │  (10.x.0.0/20)  │ │  (10.x.16.0/20) │ │  (10.x.32.0/20) │          │  │
│  │  │   [NAT GW]      │ │   [NAT GW]      │ │   [NAT GW]      │          │  │
│  │  └────────┬────────┘ └────────┬────────┘ └────────┬────────┘          │  │
│  │           │                   │                   │                    │  │
│  │  ┌────────▼────────┐ ┌────────▼────────┐ ┌────────▼────────┐          │  │
│  │  │ Private Subnet  │ │ Private Subnet  │ │ Private Subnet  │          │  │
│  │  │    AZ-1a        │ │    AZ-1b        │ │    AZ-1c        │          │  │
│  │  │  (10.x.64.0/20) │ │ (10.x.80.0/20)  │ │ (10.x.96.0/20)  │          │  │
│  │  │   [App/ECS]     │ │   [App/ECS]     │ │   [App/ECS]     │          │  │
│  │  └────────┬────────┘ └────────┬────────┘ └────────┬────────┘          │  │
│  │           │                   │                   │                    │  │
│  │  ┌────────▼────────┐ ┌────────▼────────┐ ┌────────▼────────┐          │  │
│  │  │Database Subnet  │ │Database Subnet  │ │Database Subnet  │          │  │
│  │  │    AZ-1a        │ │    AZ-1b        │ │    AZ-1c        │          │  │
│  │  │ (10.x.128.0/20) │ │(10.x.144.0/20)  │ │(10.x.160.0/20)  │          │  │
│  │  │   [RDS/Cache]   │ │   [RDS/Cache]   │ │   [RDS/Cache]   │          │  │
│  │  └─────────────────┘ └─────────────────┘ └─────────────────┘          │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                        Security Services                                 ││
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    ││
│  │  │  GuardDuty   │ │ Security Hub │ │  AWS Config  │ │   KMS Keys   │    ││
│  │  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘    ││
│  └─────────────────────────────────────────────────────────────────────────┘│
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐│
│  │                        Logging & Monitoring                              ││
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    ││
│  │  │  CloudTrail  │ │  CloudWatch  │ │   S3 Logs    │ │  VPC Flow    │    ││
│  │  │              │ │    Logs      │ │   Bucket     │ │    Logs      │    ││
│  │  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘    ││
│  └─────────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────────┘
```

## Module Structure

### 1. Networking Module
- **VPC**: Multi-AZ VPC with customizable CIDR
- **Subnets**: Public, Private, and Database tiers
- **NAT Gateway**: Configurable for HA or single instance
- **Route Tables**: Separate tables for each tier
- **VPC Flow Logs**: Enabled for security monitoring
- **VPN Gateway**: Optional for hybrid connectivity

### 2. Security Module
- **GuardDuty**: Threat detection service
- **Security Hub**: Security posture management
- **AWS Config**: Configuration compliance
- **KMS Keys**: Encryption at rest
- **Security Groups**: Pre-configured for ALB, App, DB, Bastion

### 3. Logging Module
- **CloudTrail**: API activity logging
- **CloudWatch Logs**: Centralized log management
- **S3 Bucket**: Log archival with lifecycle policies
- **SNS Topics**: Alert notifications
- **Metric Filters**: Security monitoring

### 4. IAM Module
- **Roles**: Admin, Developer, ReadOnly, CI/CD, EC2, Lambda, ECS
- **Groups**: With role assumption policies
- **Password Policy**: Strong password requirements
- **MFA Policy**: Self-service MFA management

## Environment Configurations

| Feature | Dev | Staging | Prod |
|---------|-----|---------|------|
| Availability Zones | 2 | 3 | 3 |
| NAT Gateway | Single | Single | Multi-AZ |
| VPN Gateway | No | No | Yes |
| Log Retention | 30 days | 60 days | 365 days |
| S3 Log Retention | 90 days | 180 days | 7 years |

## Security Best Practices Implemented

1. **Encryption at Rest**: All data encrypted using KMS
2. **Encryption in Transit**: TLS/HTTPS enforced
3. **MFA Required**: For admin and sensitive role assumptions
4. **Least Privilege**: Role-based access control
5. **Logging**: Comprehensive audit trail
6. **Monitoring**: Real-time threat detection
7. **Compliance**: CIS Benchmarks and AWS Best Practices

## Cost Optimization

- **Dev/Staging**: Single NAT Gateway
- **S3 Lifecycle**: Automated transition to Glacier
- **DynamoDB**: On-demand billing for state lock
- **Modular Design**: Deploy only what you need

## Next Steps

1. Configure S3 backend for state management
2. Customize environment variables
3. Deploy to dev environment first
4. Validate security posture
5. Promote to staging and production
