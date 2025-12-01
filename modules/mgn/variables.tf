# =============================================================================
# AWS MGN Module - Variables
# =============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for MGN resources"
  type        = string
}

variable "enable_mgn" {
  description = "Enable AWS MGN service"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------
variable "staging_subnet_id" {
  description = "Subnet ID for MGN staging area (replication servers)"
  type        = string
}

variable "target_subnet_ids" {
  description = "Subnet IDs for migrated instances"
  type        = list(string)
  default     = []
}

variable "replication_security_group_ids" {
  description = "Security group IDs for replication servers"
  type        = list(string)
  default     = []
}

variable "bastion_security_group_ids" {
  description = "Bastion security group IDs for SSH access"
  type        = list(string)
  default     = []
}

variable "alb_security_group_ids" {
  description = "ALB security group IDs for web traffic"
  type        = list(string)
  default     = []
}

variable "source_cidr_blocks" {
  description = "CIDR blocks of source vCenter network (for replication traffic)"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

# -----------------------------------------------------------------------------
# Replication Configuration
# -----------------------------------------------------------------------------
variable "replication_server_instance_type" {
  description = "Instance type for replication servers"
  type        = string
  default     = "t3.small"
}

variable "use_dedicated_replication_server" {
  description = "Use dedicated replication servers (recommended for production)"
  type        = bool
  default     = false
}

variable "staging_disk_type" {
  description = "EBS volume type for staging disks (GP3, GP2, ST1)"
  type        = string
  default     = "GP3"
}

variable "bandwidth_throttling" {
  description = "Bandwidth throttling in Mbps (0 = unlimited)"
  type        = number
  default     = 0
}

variable "kms_key_arn" {
  description = "KMS key ARN for EBS encryption"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Launch Configuration
# -----------------------------------------------------------------------------
variable "copy_private_ip" {
  description = "Copy private IP from source server"
  type        = bool
  default     = false
}

variable "os_byol" {
  description = "Bring Your Own License for OS"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# IAM Configuration
# -----------------------------------------------------------------------------
variable "create_agent_user" {
  description = "Create IAM user for MGN agent installation"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Security Groups
# -----------------------------------------------------------------------------
variable "create_security_groups" {
  description = "Create security groups for MGN"
  type        = bool
  default     = true
}

variable "allow_web_traffic" {
  description = "Allow HTTP/HTTPS traffic from ALB"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Logging & Notifications
# -----------------------------------------------------------------------------
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "enable_notifications" {
  description = "Enable SNS notifications for MGN events"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Source Servers (vCenter VMs)
# -----------------------------------------------------------------------------
variable "source_servers" {
  description = "Map of source servers from vCenter to migrate"
  type = map(object({
    name             = string
    source_ip        = string
    target_subnet_id = string
    instance_type    = optional(string, "")  # Empty = let MGN decide
    role             = string                 # WebServer, AppServer, Database
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
