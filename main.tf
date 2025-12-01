# =============================================================================
# AWS MAP Landing Zone - Main Configuration
# =============================================================================
# This is the main entry point for the AWS Migration Acceleration Program
# Landing Zone infrastructure using Terraform.
# =============================================================================

locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Program     = "AWS-MAP"
    },
    var.tags
  )
}

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# Networking Module
# -----------------------------------------------------------------------------
module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Security Module
# -----------------------------------------------------------------------------
module "security" {
  source = "./modules/security"

  project_name        = var.project_name
  environment         = var.environment
  vpc_id              = module.networking.vpc_id
  enable_guardduty    = var.enable_guardduty
  enable_security_hub = var.enable_security_hub
  enable_config       = var.enable_config
  log_bucket_name     = module.logging.log_bucket_name

  tags = local.common_tags

  depends_on = [module.logging]
}

# -----------------------------------------------------------------------------
# Logging Module
# -----------------------------------------------------------------------------
module "logging" {
  source = "./modules/logging"

  project_name          = var.project_name
  environment           = var.environment
  aws_region            = var.aws_region
  enable_cloudtrail     = var.enable_cloudtrail
  log_retention_days    = var.log_retention_days
  s3_log_retention_days = var.s3_log_retention_days

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# IAM Module
# -----------------------------------------------------------------------------
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Organizations Module (Control Tower Style)
# -----------------------------------------------------------------------------
module "organizations" {
  source = "./modules/organizations"

  count = var.enable_organizations ? 1 : 0

  create_organization = var.create_organization
  project_name        = var.project_name
  environment         = var.environment
  allowed_regions     = var.allowed_regions

  # Account Factory
  account_factory_enabled = var.account_factory_enabled
  accounts                = var.accounts

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Compute Module - Migrated Workloads from vCenter
# -----------------------------------------------------------------------------
module "compute" {
  source = "./modules/compute"

  count = var.enable_compute ? 1 : 0

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids

  # ALB Security Group from security module
  alb_security_group_ids = [module.security.alb_security_group_id]
  instance_profile_name  = module.iam.ec2_instance_profile_name

  # Migrated workload configuration
  web_server_count = var.web_server_count
  app_server_count = var.app_server_count
  create_alb       = var.create_alb

  # vCenter source mapping
  vcenter_source_vms = var.vcenter_source_vms

  tags = local.common_tags

  depends_on = [module.networking, module.security, module.iam]
}

# -----------------------------------------------------------------------------
# AWS MGN Module - Application Migration Service (Lift-and-Shift)
# -----------------------------------------------------------------------------
module "mgn" {
  source = "./modules/mgn"

  count = var.enable_mgn ? 1 : 0

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.networking.vpc_id

  # Staging area for replication
  staging_subnet_id = module.networking.private_subnet_ids[0]
  target_subnet_ids = module.networking.private_subnet_ids

  # Security Groups
  replication_security_group_ids = []  # Will use created SG
  bastion_security_group_ids     = [module.security.bastion_security_group_id]
  alb_security_group_ids         = [module.security.alb_security_group_id]

  # Source vCenter network
  source_cidr_blocks = var.vcenter_cidr_blocks

  # Replication settings
  replication_server_instance_type = var.mgn_replication_instance_type
  bandwidth_throttling             = var.mgn_bandwidth_throttling

  # Launch settings
  copy_private_ip = var.mgn_copy_private_ip
  os_byol         = var.mgn_os_byol

  tags = local.common_tags

  depends_on = [module.networking, module.security]
}
