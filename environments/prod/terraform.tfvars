# =============================================================================
# Production Environment Variables
# =============================================================================

project_name = "aws-map-landing-zone"
environment  = "prod"
aws_region   = "ap-southeast-1"

# Network Configuration
vpc_cidr           = "10.2.0.0/16"
availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
enable_nat_gateway = true
single_nat_gateway = false  # High availability for production
enable_vpn_gateway = true

# Security Configuration
enable_guardduty    = true
enable_security_hub = true
enable_config       = true
enable_cloudtrail   = true

# Logging Configuration
log_retention_days    = 365
s3_log_retention_days = 2555  # 7 years for compliance

# Additional Tags
tags = {
  CostCenter  = "production"
  Team        = "platform"
  Compliance  = "required"
  BackupLevel = "critical"
}
