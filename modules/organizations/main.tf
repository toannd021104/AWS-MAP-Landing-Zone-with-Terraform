# =============================================================================
# AWS Organizations - Multi-Account Landing Zone
# =============================================================================
# This module creates AWS Organizations structure similar to Control Tower
# - Organization Units (OUs)
# - Service Control Policies (SCPs)
# - Account Factory
# =============================================================================

# -----------------------------------------------------------------------------
# AWS Organization
# -----------------------------------------------------------------------------
resource "aws_organizations_organization" "main" {
  count = var.create_organization ? 1 : 0

  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com",
    "securityhub.amazonaws.com",
    "sso.amazonaws.com",
    "ram.amazonaws.com",
    "servicecatalog.amazonaws.com",
    "member.org.stacksets.cloudformation.amazonaws.com"
  ]

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "TAG_POLICY",
    "BACKUP_POLICY"
  ]

  feature_set = "ALL"
}

# -----------------------------------------------------------------------------
# Organization Units (OUs) - Control Tower Style
# -----------------------------------------------------------------------------

# Security OU - for Log Archive and Audit accounts
resource "aws_organizations_organizational_unit" "security" {
  count = var.create_organization ? 1 : 0

  name      = "Security"
  parent_id = aws_organizations_organization.main[0].roots[0].id
}

# Infrastructure OU - for shared infrastructure
resource "aws_organizations_organizational_unit" "infrastructure" {
  count = var.create_organization ? 1 : 0

  name      = "Infrastructure"
  parent_id = aws_organizations_organization.main[0].roots[0].id
}

# Workloads OU - for application accounts
resource "aws_organizations_organizational_unit" "workloads" {
  count = var.create_organization ? 1 : 0

  name      = "Workloads"
  parent_id = aws_organizations_organization.main[0].roots[0].id
}

# Sandbox OU - for development/testing
resource "aws_organizations_organizational_unit" "sandbox" {
  count = var.create_organization ? 1 : 0

  name      = "Sandbox"
  parent_id = aws_organizations_organization.main[0].roots[0].id
}

# Production OU under Workloads
resource "aws_organizations_organizational_unit" "production" {
  count = var.create_organization ? 1 : 0

  name      = "Production"
  parent_id = aws_organizations_organizational_unit.workloads[0].id
}

# Non-Production OU under Workloads
resource "aws_organizations_organizational_unit" "non_production" {
  count = var.create_organization ? 1 : 0

  name      = "Non-Production"
  parent_id = aws_organizations_organizational_unit.workloads[0].id
}

# -----------------------------------------------------------------------------
# Service Control Policies (SCPs) - Guardrails
# -----------------------------------------------------------------------------

# SCP: Deny leaving organization
resource "aws_organizations_policy" "deny_leave_org" {
  count = var.create_organization ? 1 : 0

  name        = "DenyLeaveOrganization"
  description = "Prevent accounts from leaving the organization"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyLeaveOrg"
        Effect    = "Deny"
        Action    = "organizations:LeaveOrganization"
        Resource  = "*"
      }
    ]
  })
}

# SCP: Deny root user actions
resource "aws_organizations_policy" "deny_root_user" {
  count = var.create_organization ? 1 : 0

  name        = "DenyRootUser"
  description = "Prevent root user from performing actions"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyRootUser"
        Effect    = "Deny"
        Action    = "*"
        Resource  = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:iam::*:root"
          }
        }
      }
    ]
  })
}

# SCP: Require IMDSv2
resource "aws_organizations_policy" "require_imdsv2" {
  count = var.create_organization ? 1 : 0

  name        = "RequireIMDSv2"
  description = "Require IMDSv2 for EC2 instances"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "RequireIMDSv2"
        Effect    = "Deny"
        Action    = "ec2:RunInstances"
        Resource  = "arn:aws:ec2:*:*:instance/*"
        Condition = {
          StringNotEquals = {
            "ec2:MetadataHttpTokens" = "required"
          }
        }
      }
    ]
  })
}

# SCP: Deny disabling security services
resource "aws_organizations_policy" "protect_security_services" {
  count = var.create_organization ? 1 : 0

  name        = "ProtectSecurityServices"
  description = "Prevent disabling security services"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ProtectGuardDuty"
        Effect = "Deny"
        Action = [
          "guardduty:DeleteDetector",
          "guardduty:DisassociateFromMasterAccount",
          "guardduty:DisassociateMembers",
          "guardduty:StopMonitoringMembers"
        ]
        Resource = "*"
      },
      {
        Sid    = "ProtectSecurityHub"
        Effect = "Deny"
        Action = [
          "securityhub:DisableSecurityHub",
          "securityhub:DisassociateFromMasterAccount"
        ]
        Resource = "*"
      },
      {
        Sid    = "ProtectCloudTrail"
        Effect = "Deny"
        Action = [
          "cloudtrail:DeleteTrail",
          "cloudtrail:StopLogging",
          "cloudtrail:UpdateTrail"
        ]
        Resource = "*"
      },
      {
        Sid    = "ProtectConfig"
        Effect = "Deny"
        Action = [
          "config:DeleteConfigurationRecorder",
          "config:DeleteDeliveryChannel",
          "config:StopConfigurationRecorder"
        ]
        Resource = "*"
      }
    ]
  })
}

# SCP: Restrict regions
resource "aws_organizations_policy" "restrict_regions" {
  count = var.create_organization && length(var.allowed_regions) > 0 ? 1 : 0

  name        = "RestrictRegions"
  description = "Restrict AWS regions"
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyOtherRegions"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = var.allowed_regions
          }
          ArnNotLike = {
            "aws:PrincipalARN" = "arn:aws:iam::*:role/OrganizationAccountAccessRole"
          }
        }
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# Attach SCPs to OUs
# -----------------------------------------------------------------------------

# Attach deny leave org to root
resource "aws_organizations_policy_attachment" "deny_leave_org_root" {
  count = var.create_organization ? 1 : 0

  policy_id = aws_organizations_policy.deny_leave_org[0].id
  target_id = aws_organizations_organization.main[0].roots[0].id
}

# Attach protect security services to workloads OU
resource "aws_organizations_policy_attachment" "protect_security_workloads" {
  count = var.create_organization ? 1 : 0

  policy_id = aws_organizations_policy.protect_security_services[0].id
  target_id = aws_organizations_organizational_unit.workloads[0].id
}

# Attach require IMDSv2 to production OU
resource "aws_organizations_policy_attachment" "require_imdsv2_prod" {
  count = var.create_organization ? 1 : 0

  policy_id = aws_organizations_policy.require_imdsv2[0].id
  target_id = aws_organizations_organizational_unit.production[0].id
}

# Attach deny root user to all except sandbox
resource "aws_organizations_policy_attachment" "deny_root_production" {
  count = var.create_organization ? 1 : 0

  policy_id = aws_organizations_policy.deny_root_user[0].id
  target_id = aws_organizations_organizational_unit.production[0].id
}

# -----------------------------------------------------------------------------
# Account Factory - Create Member Accounts
# -----------------------------------------------------------------------------
locals {
  ou_map = var.create_organization ? {
    security        = aws_organizations_organizational_unit.security[0].id
    infrastructure  = aws_organizations_organizational_unit.infrastructure[0].id
    workloads       = aws_organizations_organizational_unit.workloads[0].id
    sandbox         = aws_organizations_organizational_unit.sandbox[0].id
    production      = aws_organizations_organizational_unit.production[0].id
    non_production  = aws_organizations_organizational_unit.non_production[0].id
  } : {}
}

resource "aws_organizations_account" "accounts" {
  for_each = var.account_factory_enabled && var.create_organization ? var.accounts : {}

  name      = each.key
  email     = each.value.email
  role_name = each.value.role_name
  parent_id = local.ou_map[each.value.ou]

  # Prevent accidental deletion
  lifecycle {
    prevent_destroy = false  # Set to true in production
  }

  tags = merge(var.tags, {
    Name        = each.key
    Environment = each.value.ou
  })
}
