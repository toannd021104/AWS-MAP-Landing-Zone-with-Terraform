# =============================================================================
# Transit Gateway - Hub-and-Spoke Network Architecture
# =============================================================================
# Reference: AWS Whitepaper - Building Scalable and Secure Multi-VPC Network
# https://docs.aws.amazon.com/whitepapers/latest/building-scalable-secure-multi-vpc-network-infrastructure
# =============================================================================

# -----------------------------------------------------------------------------
# Transit Gateway
# -----------------------------------------------------------------------------
resource "aws_ec2_transit_gateway" "main" {
  count = var.enable_transit_gateway ? 1 : 0

  description                     = "Transit Gateway for ${local.name_prefix}"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-tgw"
  })
}

# -----------------------------------------------------------------------------
# Transit Gateway Route Tables
# -----------------------------------------------------------------------------

# Spoke Route Table - for workload VPCs
resource "aws_ec2_transit_gateway_route_table" "spoke" {
  count = var.enable_transit_gateway ? 1 : 0

  transit_gateway_id = aws_ec2_transit_gateway.main[0].id

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-tgw-rt-spoke"
    Type = "Spoke"
  })
}

# Shared Services Route Table - for shared/hub VPC
resource "aws_ec2_transit_gateway_route_table" "shared" {
  count = var.enable_transit_gateway ? 1 : 0

  transit_gateway_id = aws_ec2_transit_gateway.main[0].id

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-tgw-rt-shared"
    Type = "Shared"
  })
}

# Inspection Route Table - for Network Firewall (optional)
resource "aws_ec2_transit_gateway_route_table" "inspection" {
  count = var.enable_transit_gateway && var.enable_network_firewall ? 1 : 0

  transit_gateway_id = aws_ec2_transit_gateway.main[0].id

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-tgw-rt-inspection"
    Type = "Inspection"
  })
}

# -----------------------------------------------------------------------------
# Transit Gateway VPC Attachment - Main VPC
# -----------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  count = var.enable_transit_gateway ? 1 : 0

  transit_gateway_id = aws_ec2_transit_gateway.main[0].id
  vpc_id             = aws_vpc.main.id
  subnet_ids         = aws_subnet.private[*].id

  dns_support                                     = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-tgw-attach-main"
  })
}

# Associate main VPC with spoke route table
resource "aws_ec2_transit_gateway_route_table_association" "main" {
  count = var.enable_transit_gateway ? 1 : 0

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke[0].id
}

# Propagate main VPC routes to shared route table
resource "aws_ec2_transit_gateway_route_table_propagation" "main_to_shared" {
  count = var.enable_transit_gateway ? 1 : 0

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.main[0].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.shared[0].id
}

# -----------------------------------------------------------------------------
# Routes from Private Subnets to Transit Gateway
# -----------------------------------------------------------------------------
resource "aws_route" "private_to_tgw" {
  count = var.enable_transit_gateway && length(var.tgw_destination_cidrs) > 0 ? length(var.tgw_destination_cidrs) * length(aws_route_table.private) : 0

  route_table_id         = aws_route_table.private[floor(count.index / length(var.tgw_destination_cidrs))].id
  destination_cidr_block = var.tgw_destination_cidrs[count.index % length(var.tgw_destination_cidrs)]
  transit_gateway_id     = aws_ec2_transit_gateway.main[0].id
}

# -----------------------------------------------------------------------------
# Resource Access Manager (RAM) Share - for multi-account
# -----------------------------------------------------------------------------
resource "aws_ram_resource_share" "tgw" {
  count = var.enable_transit_gateway && var.share_transit_gateway ? 1 : 0

  name                      = "${local.name_prefix}-tgw-share"
  allow_external_principals = false

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-tgw-share"
  })
}

resource "aws_ram_resource_association" "tgw" {
  count = var.enable_transit_gateway && var.share_transit_gateway ? 1 : 0

  resource_arn       = aws_ec2_transit_gateway.main[0].arn
  resource_share_arn = aws_ram_resource_share.tgw[0].arn
}

# Share with AWS Organization (if specified)
resource "aws_ram_principal_association" "tgw_org" {
  count = var.enable_transit_gateway && var.share_transit_gateway && var.organization_arn != "" ? 1 : 0

  principal          = var.organization_arn
  resource_share_arn = aws_ram_resource_share.tgw[0].arn
}
