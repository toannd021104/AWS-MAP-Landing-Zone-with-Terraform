# =============================================================================
# Staging Environment Variables
# =============================================================================

project_name = "aws-map-landing-zone"
environment  = "staging"
aws_region   = "ap-southeast-1"

# Network Configuration
vpc_cidr           = "10.1.0.0/16"
availability_zones = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
enable_nat_gateway = true
single_nat_gateway = true  # Cost optimization for staging
enable_vpn_gateway = false

# Security Configuration
enable_guardduty    = true
enable_security_hub = true
enable_config       = true
enable_cloudtrail   = true

# Logging Configuration
log_retention_days    = 60
s3_log_retention_days = 180

# Additional Tags
tags = {
  CostCenter = "staging"
  Team       = "platform"
}
