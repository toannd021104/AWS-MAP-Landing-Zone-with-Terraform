#!/bin/bash
# =============================================================================
# AWS MAP Landing Zone - Terraform Initialization Script
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
ENVIRONMENT="${1:-dev}"
ACTION="${2:-plan}"
AWS_REGION="${AWS_REGION:-ap-southeast-1}"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
    echo -e "${RED}Error: Invalid environment. Use: dev, staging, or prod${NC}"
    exit 1
fi

# Validate action
if [[ ! "$ACTION" =~ ^(init|plan|apply|destroy)$ ]]; then
    echo -e "${RED}Error: Invalid action. Use: init, plan, apply, or destroy${NC}"
    exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}AWS MAP Landing Zone - Terraform${NC}"
echo -e "${GREEN}Environment: ${YELLOW}$ENVIRONMENT${NC}"
echo -e "${GREEN}Action: ${YELLOW}$ACTION${NC}"
echo -e "${GREEN}Region: ${YELLOW}$AWS_REGION${NC}"
echo -e "${GREEN}========================================${NC}"

# Change to project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# Check AWS credentials
echo -e "\n${YELLOW}Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo -e "${RED}Error: AWS credentials not configured or invalid${NC}"
    exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${GREEN}AWS Account: $AWS_ACCOUNT_ID${NC}"

# Environment-specific tfvars file
TFVARS_FILE="environments/$ENVIRONMENT/terraform.tfvars"

if [ ! -f "$TFVARS_FILE" ]; then
    echo -e "${RED}Error: Environment file not found: $TFVARS_FILE${NC}"
    exit 1
fi

case $ACTION in
    init)
        echo -e "\n${YELLOW}Initializing Terraform...${NC}"
        terraform init -upgrade
        ;;
    plan)
        echo -e "\n${YELLOW}Running Terraform plan...${NC}"
        terraform plan -var-file="$TFVARS_FILE" -out="tfplan-$ENVIRONMENT"
        ;;
    apply)
        echo -e "\n${YELLOW}Applying Terraform configuration...${NC}"
        if [ -f "tfplan-$ENVIRONMENT" ]; then
            terraform apply "tfplan-$ENVIRONMENT"
        else
            terraform apply -var-file="$TFVARS_FILE"
        fi
        ;;
    destroy)
        echo -e "\n${RED}WARNING: This will destroy all resources!${NC}"
        read -p "Are you sure you want to destroy $ENVIRONMENT environment? (yes/no): " confirm
        if [ "$confirm" == "yes" ]; then
            terraform destroy -var-file="$TFVARS_FILE"
        else
            echo -e "${YELLOW}Destroy cancelled.${NC}"
        fi
        ;;
esac

echo -e "\n${GREEN}Done!${NC}"
