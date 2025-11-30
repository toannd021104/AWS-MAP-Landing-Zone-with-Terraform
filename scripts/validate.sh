#!/bin/bash
# =============================================================================
# AWS MAP Landing Zone - Validation Script
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}AWS MAP Landing Zone - Validation${NC}"
echo -e "${GREEN}========================================${NC}"

ERRORS=0

# Check Terraform version
echo -e "\n${YELLOW}Checking Terraform version...${NC}"
if command -v terraform &> /dev/null; then
    TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
    echo -e "${GREEN}Terraform version: $TF_VERSION${NC}"
else
    echo -e "${RED}Terraform is not installed${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check AWS CLI
echo -e "\n${YELLOW}Checking AWS CLI...${NC}"
if command -v aws &> /dev/null; then
    AWS_VERSION=$(aws --version | cut -d' ' -f1 | cut -d'/' -f2)
    echo -e "${GREEN}AWS CLI version: $AWS_VERSION${NC}"
else
    echo -e "${RED}AWS CLI is not installed${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check AWS credentials
echo -e "\n${YELLOW}Checking AWS credentials...${NC}"
if aws sts get-caller-identity > /dev/null 2>&1; then
    AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    AWS_ARN=$(aws sts get-caller-identity --query Arn --output text)
    echo -e "${GREEN}AWS Account: $AWS_ACCOUNT${NC}"
    echo -e "${GREEN}AWS ARN: $AWS_ARN${NC}"
else
    echo -e "${RED}AWS credentials not configured${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Validate Terraform configuration
echo -e "\n${YELLOW}Validating Terraform configuration...${NC}"
if terraform validate; then
    echo -e "${GREEN}Terraform configuration is valid${NC}"
else
    echo -e "${RED}Terraform configuration is invalid${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check Terraform formatting
echo -e "\n${YELLOW}Checking Terraform formatting...${NC}"
if terraform fmt -check -recursive; then
    echo -e "${GREEN}Terraform files are properly formatted${NC}"
else
    echo -e "${YELLOW}Some files need formatting. Run: terraform fmt -recursive${NC}"
fi

# Check required files
echo -e "\n${YELLOW}Checking required files...${NC}"
REQUIRED_FILES=(
    "main.tf"
    "variables.tf"
    "outputs.tf"
    "providers.tf"
    "versions.tf"
    "modules/networking/main.tf"
    "modules/security/main.tf"
    "modules/logging/main.tf"
    "modules/iam/main.tf"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}  [OK] $file${NC}"
    else
        echo -e "${RED}  [MISSING] $file${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check environment files
echo -e "\n${YELLOW}Checking environment files...${NC}"
for env in dev staging prod; do
    if [ -f "environments/$env/terraform.tfvars" ]; then
        echo -e "${GREEN}  [OK] environments/$env/terraform.tfvars${NC}"
    else
        echo -e "${RED}  [MISSING] environments/$env/terraform.tfvars${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done

# Summary
echo -e "\n${GREEN}========================================${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}Validation passed! No errors found.${NC}"
else
    echo -e "${RED}Validation failed! Found $ERRORS error(s).${NC}"
    exit 1
fi
echo -e "${GREEN}========================================${NC}"
