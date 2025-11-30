# =============================================================================
# Development Environment Variables
# =============================================================================

project_name = "aws-map-landing-zone"
environment  = "dev"
aws_region   = "ap-southeast-1"

# Network Configuration
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["ap-southeast-1a", "ap-southeast-1b"]
enable_nat_gateway = true
single_nat_gateway = true  # Cost optimization for dev
enable_vpn_gateway = false

# Security Configuration
enable_guardduty    = true
enable_security_hub = true
enable_config       = true
enable_cloudtrail   = true

# Logging Configuration
log_retention_days    = 30
s3_log_retention_days = 365  # Must be > 180 (Glacier transition)

# Additional Tags
tags = {
  CostCenter = "development"
  Team       = "platform"
}

# Organizations Configuration (Control Tower Style)
enable_organizations = false  # Set to true to enable AWS Organizations
create_organization  = true   # Set to false if organization already exists
allowed_regions      = ["ap-southeast-1", "ap-southeast-2"]  # Allowed regions

# Account Factory (example - customize as needed)
account_factory_enabled = false
# accounts = {
#   "log-archive" = {
#     email = "log-archive@example.com"
#     ou    = "security"
#   }
#   "audit" = {
#     email = "audit@example.com"
#     ou    = "security"
#   }
#   "shared-services" = {
#     email = "shared@example.com"
#     ou    = "infrastructure"
#   }
#   "workload-prod" = {
#     email = "prod@example.com"
#     ou    = "production"
#   }
#   "workload-dev" = {
#     email = "dev@example.com"
#     ou    = "non_production"
#   }
# }
