# =============================================================================
# AWS Organizations Module - Outputs
# =============================================================================

output "organization_id" {
  description = "ID of the AWS Organization"
  value       = var.create_organization ? aws_organizations_organization.main[0].id : null
}

output "organization_arn" {
  description = "ARN of the AWS Organization"
  value       = var.create_organization ? aws_organizations_organization.main[0].arn : null
}

output "organization_root_id" {
  description = "ID of the Organization Root"
  value       = var.create_organization ? aws_organizations_organization.main[0].roots[0].id : null
}

output "master_account_id" {
  description = "ID of the Management Account"
  value       = var.create_organization ? aws_organizations_organization.main[0].master_account_id : null
}

# -----------------------------------------------------------------------------
# Organization Unit IDs
# -----------------------------------------------------------------------------
output "ou_security_id" {
  description = "ID of the Security OU"
  value       = var.create_organization ? aws_organizations_organizational_unit.security[0].id : null
}

output "ou_infrastructure_id" {
  description = "ID of the Infrastructure OU"
  value       = var.create_organization ? aws_organizations_organizational_unit.infrastructure[0].id : null
}

output "ou_workloads_id" {
  description = "ID of the Workloads OU"
  value       = var.create_organization ? aws_organizations_organizational_unit.workloads[0].id : null
}

output "ou_sandbox_id" {
  description = "ID of the Sandbox OU"
  value       = var.create_organization ? aws_organizations_organizational_unit.sandbox[0].id : null
}

output "ou_production_id" {
  description = "ID of the Production OU"
  value       = var.create_organization ? aws_organizations_organizational_unit.production[0].id : null
}

output "ou_non_production_id" {
  description = "ID of the Non-Production OU"
  value       = var.create_organization ? aws_organizations_organizational_unit.non_production[0].id : null
}

# -----------------------------------------------------------------------------
# SCP IDs
# -----------------------------------------------------------------------------
output "scp_deny_leave_org_id" {
  description = "ID of the Deny Leave Organization SCP"
  value       = var.create_organization ? aws_organizations_policy.deny_leave_org[0].id : null
}

output "scp_deny_root_user_id" {
  description = "ID of the Deny Root User SCP"
  value       = var.create_organization ? aws_organizations_policy.deny_root_user[0].id : null
}

output "scp_require_imdsv2_id" {
  description = "ID of the Require IMDSv2 SCP"
  value       = var.create_organization ? aws_organizations_policy.require_imdsv2[0].id : null
}

output "scp_protect_security_services_id" {
  description = "ID of the Protect Security Services SCP"
  value       = var.create_organization ? aws_organizations_policy.protect_security_services[0].id : null
}

output "scp_restrict_regions_id" {
  description = "ID of the Restrict Regions SCP"
  value       = var.create_organization && length(var.allowed_regions) > 0 ? aws_organizations_policy.restrict_regions[0].id : null
}

# -----------------------------------------------------------------------------
# Account Factory Outputs
# -----------------------------------------------------------------------------
output "created_accounts" {
  description = "Map of created accounts"
  value = var.account_factory_enabled ? {
    for k, v in aws_organizations_account.accounts : k => {
      id    = v.id
      arn   = v.arn
      email = v.email
    }
  } : {}
}
