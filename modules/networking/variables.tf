# =============================================================================
# Networking Module - Variables
# =============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Transit Gateway Variables
# -----------------------------------------------------------------------------
variable "enable_transit_gateway" {
  description = "Enable Transit Gateway for hub-and-spoke architecture"
  type        = bool
  default     = false
}

variable "enable_network_firewall" {
  description = "Enable AWS Network Firewall for centralized inspection"
  type        = bool
  default     = false
}

variable "share_transit_gateway" {
  description = "Share Transit Gateway via RAM for multi-account"
  type        = bool
  default     = false
}

variable "organization_arn" {
  description = "AWS Organization ARN for RAM sharing"
  type        = string
  default     = ""
}

variable "tgw_destination_cidrs" {
  description = "List of destination CIDRs to route through Transit Gateway"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# VPC Endpoints Variables
# -----------------------------------------------------------------------------
variable "enable_vpc_endpoints" {
  description = "Enable VPC Endpoints for AWS services (PrivateLink)"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Route 53 Variables
# -----------------------------------------------------------------------------
variable "enable_private_hosted_zone" {
  description = "Enable Route 53 Private Hosted Zone"
  type        = bool
  default     = false
}

variable "private_domain_name" {
  description = "Domain name for private hosted zone"
  type        = string
  default     = "internal.local"
}

variable "enable_route53_resolver" {
  description = "Enable Route 53 Resolver for hybrid DNS"
  type        = bool
  default     = false
}

variable "onprem_dns_servers" {
  description = "List of on-premises DNS server IPs for forwarding"
  type        = list(string)
  default     = []
}

variable "onprem_domain_name" {
  description = "On-premises domain name for DNS forwarding"
  type        = string
  default     = "corp.local"
}
