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

# =============================================================================
# Compute - Migrated Workloads from vCenter (AWS MGN)
# =============================================================================
enable_compute   = true   # Enable to deploy migrated workloads
web_server_count = 2      # PROD-WEB-01, PROD-WEB-02
app_server_count = 2      # PROD-APP-01, PROD-APP-02
create_alb       = true   # Application Load Balancer for web tier

# vCenter Source VMs (for migration tracking tags)
vcenter_source_vms = [
  {
    name       = "PROD-WEB-01"
    datacenter = "DC-HCM"
    cluster    = "Cluster-Prod"
    ip_address = "192.168.1.10"
  },
  {
    name       = "PROD-WEB-02"
    datacenter = "DC-HCM"
    cluster    = "Cluster-Prod"
    ip_address = "192.168.1.11"
  },
  {
    name       = "PROD-APP-01"
    datacenter = "DC-HCM"
    cluster    = "Cluster-Prod"
    ip_address = "192.168.1.20"
  },
  {
    name       = "PROD-APP-02"
    datacenter = "DC-HCM"
    cluster    = "Cluster-Prod"
    ip_address = "192.168.1.21"
  }
]

# =============================================================================
# AWS MGN - Application Migration Service (Lift-and-Shift)
# =============================================================================
enable_mgn = true  # Enable AWS MGN for lift-and-shift migration

# vCenter network CIDR (source servers)
vcenter_cidr_blocks = ["192.168.1.0/24"]  # DC-HCM network

# MGN Replication Settings
mgn_replication_instance_type = "t3.small"
mgn_bandwidth_throttling      = 0  # Unlimited

# MGN Launch Settings
mgn_copy_private_ip = false  # Don't copy private IP (use AWS DHCP)
mgn_os_byol         = false  # Use AWS provided license
