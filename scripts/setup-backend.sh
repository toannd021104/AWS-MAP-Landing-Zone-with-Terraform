#!/bin/bash
# =============================================================================
# AWS MAP Landing Zone - S3 Backend Setup Script
# Using S3 native locking (Terraform 1.10+) - no DynamoDB required!
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
AWS_REGION="${AWS_REGION:-ap-southeast-1}"
PROJECT_NAME="${PROJECT_NAME:-aws-map-landing-zone}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setting up Terraform S3 Backend${NC}"
echo -e "${GREEN}(Using S3 Native Locking)${NC}"
echo -e "${GREEN}========================================${NC}"

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="${PROJECT_NAME}-tfstate-${AWS_ACCOUNT_ID}"

echo -e "\n${YELLOW}Configuration:${NC}"
echo -e "  Region: $AWS_REGION"
echo -e "  S3 Bucket: $BUCKET_NAME"
echo -e "  Locking: S3 native (use_lockfile = true)"

# Create S3 bucket
echo -e "\n${YELLOW}Creating S3 bucket...${NC}"
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo -e "${GREEN}Bucket already exists${NC}"
else
    if [ "$AWS_REGION" == "us-east-1" ]; then
        aws s3api create-bucket \
            --bucket "$BUCKET_NAME" \
            --region "$AWS_REGION"
    else
        aws s3api create-bucket \
            --bucket "$BUCKET_NAME" \
            --region "$AWS_REGION" \
            --create-bucket-configuration LocationConstraint="$AWS_REGION"
    fi
    echo -e "${GREEN}Bucket created${NC}"
fi

# Enable versioning
echo -e "\n${YELLOW}Enabling versioning...${NC}"
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled

# Enable encryption
echo -e "\n${YELLOW}Enabling encryption...${NC}"
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "aws:kms"
            },
            "BucketKeyEnabled": true
        }]
    }'

# Block public access
echo -e "\n${YELLOW}Blocking public access...${NC}"
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration '{
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }'

# Output backend configuration
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Backend Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}Add this to your backend.tf:${NC}"
echo ""
cat << EOF
terraform {
  backend "s3" {
    bucket       = "$BUCKET_NAME"
    key          = "aws-map-landing-zone/terraform.tfstate"
    region       = "$AWS_REGION"
    encrypt      = true
    use_lockfile = true  # S3 native locking (Terraform 1.10+)
  }
}
EOF

echo -e "\n${GREEN}Note: S3 native locking requires Terraform >= 1.10.0${NC}"
