# =============================================================================
# AWS Organizations Module - Variables
# =============================================================================

variable "create_organization" {
  description = "Whether to create AWS Organization (set false if already exists)"
  type        = bool
  default     = true
}

variable "allowed_regions" {
  description = "List of allowed AWS regions (empty = no restriction)"
  type        = list(string)
  default     = []
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Account Factory Variables
# -----------------------------------------------------------------------------
variable "account_factory_enabled" {
  description = "Enable Account Factory for creating new accounts"
  type        = bool
  default     = false
}

variable "accounts" {
  description = "Map of accounts to create"
  type = map(object({
    email     = string
    ou        = string  # security, infrastructure, workloads, sandbox, production, non_production
    role_name = optional(string, "OrganizationAccountAccessRole")
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# SCP Configuration
# -----------------------------------------------------------------------------
variable "enable_deny_leave_org" {
  description = "Enable SCP to deny leaving organization"
  type        = bool
  default     = true
}

variable "enable_deny_root_user" {
  description = "Enable SCP to deny root user actions"
  type        = bool
  default     = true
}

variable "enable_require_imdsv2" {
  description = "Enable SCP to require IMDSv2 for EC2"
  type        = bool
  default     = true
}

variable "enable_protect_security_services" {
  description = "Enable SCP to protect security services"
  type        = bool
  default     = true
}

variable "enable_restrict_regions" {
  description = "Enable SCP to restrict AWS regions"
  type        = bool
  default     = false
}
