# =============================================================================
# AWS MAP Landing Zone - Terraform Version Requirements
# =============================================================================

terraform {
  required_version = ">= 1.10.0"  # Required for S3 native locking (use_lockfile)

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
