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
