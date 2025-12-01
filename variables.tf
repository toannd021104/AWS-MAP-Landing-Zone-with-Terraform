# =============================================================================
# AWS MAP Landing Zone - Global Variables
# =============================================================================

# -----------------------------------------------------------------------------
# General Configuration
# -----------------------------------------------------------------------------
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "aws-map-landing-zone"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-1"
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway (cost optimization for non-prod)"
  type        = bool
  default     = false
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Security Configuration
# -----------------------------------------------------------------------------
variable "enable_guardduty" {
  description = "Enable AWS GuardDuty"
  type        = bool
  default     = true
}

variable "enable_security_hub" {
  description = "Enable AWS Security Hub"
  type        = bool
  default     = true
}

variable "enable_config" {
  description = "Enable AWS Config"
  type        = bool
  default     = true
}

variable "enable_cloudtrail" {
  description = "Enable AWS CloudTrail"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Logging Configuration
# -----------------------------------------------------------------------------
variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 90
}

variable "s3_log_retention_days" {
  description = "S3 logs retention in days"
  type        = number
  default     = 365
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Organizations Configuration (Control Tower Style)
# -----------------------------------------------------------------------------
variable "enable_organizations" {
  description = "Enable AWS Organizations module"
  type        = bool
  default     = false
}

variable "create_organization" {
  description = "Create new AWS Organization (false if already exists)"
  type        = bool
  default     = true
}

variable "allowed_regions" {
  description = "List of allowed AWS regions for SCP (empty = no restriction)"
  type        = list(string)
  default     = []
}

variable "account_factory_enabled" {
  description = "Enable Account Factory for creating member accounts"
  type        = bool
  default     = false
}

variable "accounts" {
  description = "Map of accounts to create via Account Factory"
  type = map(object({
    email     = string
    ou        = string
    role_name = optional(string, "OrganizationAccountAccessRole")
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# Compute Configuration - vCenter Migration (AWS MGN)
# -----------------------------------------------------------------------------
variable "enable_compute" {
  description = "Enable compute module for migrated workloads"
  type        = bool
  default     = false
}

variable "web_server_count" {
  description = "Number of web servers to migrate"
  type        = number
  default     = 2
}

variable "app_server_count" {
  description = "Number of application servers to migrate"
  type        = number
  default     = 2
}

variable "create_alb" {
  description = "Create Application Load Balancer for web tier"
  type        = bool
  default     = true
}

variable "vcenter_source_vms" {
  description = "List of source VMs from vCenter for migration tracking"
  type = list(object({
    name       = string
    datacenter = string
    cluster    = string
    ip_address = string
  }))
  default = [
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
}

# -----------------------------------------------------------------------------
# AWS MGN Configuration - Application Migration Service
# -----------------------------------------------------------------------------
variable "enable_mgn" {
  description = "Enable AWS Application Migration Service (MGN)"
  type        = bool
  default     = false
}

variable "vcenter_cidr_blocks" {
  description = "CIDR blocks of source vCenter network for MGN replication"
  type        = list(string)
  default     = ["192.168.0.0/16", "10.0.0.0/8", "172.16.0.0/12"]
}

variable "mgn_replication_instance_type" {
  description = "Instance type for MGN replication servers"
  type        = string
  default     = "t3.small"
}

variable "mgn_bandwidth_throttling" {
  description = "Bandwidth throttling for MGN replication in Mbps (0 = unlimited)"
  type        = number
  default     = 0
}

variable "mgn_copy_private_ip" {
  description = "Copy private IP from source server to target"
  type        = bool
  default     = false
}

variable "mgn_os_byol" {
  description = "Bring Your Own License for OS"
  type        = bool
  default     = false
}
