# =============================================================================
# AWS MAP Landing Zone - Outputs
# =============================================================================

# -----------------------------------------------------------------------------
# VPC Outputs
# -----------------------------------------------------------------------------
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = module.networking.database_subnet_ids
}

# -----------------------------------------------------------------------------
# Security Outputs
# -----------------------------------------------------------------------------
output "guardduty_detector_id" {
  description = "GuardDuty Detector ID"
  value       = var.enable_guardduty ? module.security.guardduty_detector_id : null
}

output "security_hub_arn" {
  description = "Security Hub ARN"
  value       = var.enable_security_hub ? module.security.security_hub_arn : null
}

# -----------------------------------------------------------------------------
# Logging Outputs
# -----------------------------------------------------------------------------
output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = var.enable_cloudtrail ? module.logging.cloudtrail_arn : null
}

output "log_bucket_name" {
  description = "S3 bucket name for logs"
  value       = module.logging.log_bucket_name
}

output "log_bucket_arn" {
  description = "S3 bucket ARN for logs"
  value       = module.logging.log_bucket_arn
}

# -----------------------------------------------------------------------------
# IAM Outputs
# -----------------------------------------------------------------------------
output "admin_role_arn" {
  description = "Admin IAM Role ARN"
  value       = module.iam.admin_role_arn
}

output "developer_role_arn" {
  description = "Developer IAM Role ARN"
  value       = module.iam.developer_role_arn
}

output "readonly_role_arn" {
  description = "ReadOnly IAM Role ARN"
  value       = module.iam.readonly_role_arn
}

# -----------------------------------------------------------------------------
# Organizations Outputs (Control Tower Style)
# -----------------------------------------------------------------------------
output "organization_id" {
  description = "AWS Organization ID"
  value       = var.enable_organizations ? module.organizations[0].organization_id : null
}

output "organization_root_id" {
  description = "AWS Organization Root ID"
  value       = var.enable_organizations ? module.organizations[0].organization_root_id : null
}

output "ou_security_id" {
  description = "Security OU ID"
  value       = var.enable_organizations ? module.organizations[0].ou_security_id : null
}

output "ou_workloads_id" {
  description = "Workloads OU ID"
  value       = var.enable_organizations ? module.organizations[0].ou_workloads_id : null
}

output "ou_production_id" {
  description = "Production OU ID"
  value       = var.enable_organizations ? module.organizations[0].ou_production_id : null
}

output "ou_sandbox_id" {
  description = "Sandbox OU ID"
  value       = var.enable_organizations ? module.organizations[0].ou_sandbox_id : null
}
