# =============================================================================
# Compute Module - Variables
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
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
  default     = []
}

variable "alb_security_group_ids" {
  description = "ALB security group IDs"
  type        = list(string)
  default     = []
}

variable "instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
  default     = ""
}

variable "ami_id" {
  description = "AMI ID for instances (empty = latest Amazon Linux)"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Web Server Configuration
# -----------------------------------------------------------------------------
variable "web_server_count" {
  description = "Number of web servers to create"
  type        = number
  default     = 2
}

variable "web_instance_type" {
  description = "Instance type for web servers"
  type        = string
  default     = "t3.medium"
}

variable "web_root_volume_size" {
  description = "Root volume size in GB for web servers"
  type        = number
  default     = 50
}

# -----------------------------------------------------------------------------
# Application Server Configuration
# -----------------------------------------------------------------------------
variable "app_server_count" {
  description = "Number of application servers to create"
  type        = number
  default     = 2
}

variable "app_instance_type" {
  description = "Instance type for application servers"
  type        = string
  default     = "t3.large"
}

variable "app_root_volume_size" {
  description = "Root volume size in GB for application servers"
  type        = number
  default     = 100
}

# -----------------------------------------------------------------------------
# ALB Configuration
# -----------------------------------------------------------------------------
variable "create_alb" {
  description = "Create Application Load Balancer"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# vCenter Source VM Mapping (for migration tracking)
# -----------------------------------------------------------------------------
variable "vcenter_source_vms" {
  description = "List of source VMs from vCenter"
  type = list(object({
    name       = string
    datacenter = string
    cluster    = string
    ip_address = string
  }))
  default = [
    {
      name       = "vcenter-web-01"
      datacenter = "DC-HCM"
      cluster    = "Cluster-Prod"
      ip_address = "192.168.1.10"
    },
    {
      name       = "vcenter-web-02"
      datacenter = "DC-HCM"
      cluster    = "Cluster-Prod"
      ip_address = "192.168.1.11"
    },
    {
      name       = "vcenter-app-01"
      datacenter = "DC-HCM"
      cluster    = "Cluster-Prod"
      ip_address = "192.168.1.20"
    },
    {
      name       = "vcenter-app-02"
      datacenter = "DC-HCM"
      cluster    = "Cluster-Prod"
      ip_address = "192.168.1.21"
    }
  ]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
