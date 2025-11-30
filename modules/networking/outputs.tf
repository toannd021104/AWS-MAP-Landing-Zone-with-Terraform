# =============================================================================
# Networking Module - Outputs
# =============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = aws_subnet.database[*].id
}

output "database_subnet_cidrs" {
  description = "List of database subnet CIDR blocks"
  value       = aws_subnet.database[*].cidr_block
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = aws_db_subnet_group.database.name
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IPs"
  value       = aws_eip.nat[*].public_ip
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.private[*].id
}

output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = var.enable_vpn_gateway ? aws_vpn_gateway.main[0].id : null
}

output "vpc_flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = aws_flow_log.main.id
}

output "vpc_flow_log_group_arn" {
  description = "ARN of the VPC Flow Log CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.arn
}

# -----------------------------------------------------------------------------
# Transit Gateway Outputs
# -----------------------------------------------------------------------------
output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = var.enable_transit_gateway ? aws_ec2_transit_gateway.main[0].id : null
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway"
  value       = var.enable_transit_gateway ? aws_ec2_transit_gateway.main[0].arn : null
}

output "transit_gateway_attachment_id" {
  description = "ID of the Transit Gateway VPC Attachment"
  value       = var.enable_transit_gateway ? aws_ec2_transit_gateway_vpc_attachment.main[0].id : null
}

output "transit_gateway_route_table_spoke_id" {
  description = "ID of the Spoke Route Table"
  value       = var.enable_transit_gateway ? aws_ec2_transit_gateway_route_table.spoke[0].id : null
}

output "transit_gateway_route_table_shared_id" {
  description = "ID of the Shared Route Table"
  value       = var.enable_transit_gateway ? aws_ec2_transit_gateway_route_table.shared[0].id : null
}

# -----------------------------------------------------------------------------
# VPC Endpoints Outputs
# -----------------------------------------------------------------------------
output "vpc_endpoint_s3_id" {
  description = "ID of S3 VPC Endpoint"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.s3[0].id : null
}

output "vpc_endpoint_dynamodb_id" {
  description = "ID of DynamoDB VPC Endpoint"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.dynamodb[0].id : null
}

output "vpc_endpoints_security_group_id" {
  description = "Security Group ID for VPC Endpoints"
  value       = var.enable_vpc_endpoints ? aws_security_group.vpc_endpoints[0].id : null
}

# -----------------------------------------------------------------------------
# Route 53 Outputs
# -----------------------------------------------------------------------------
output "private_hosted_zone_id" {
  description = "ID of the Private Hosted Zone"
  value       = var.enable_private_hosted_zone ? aws_route53_zone.private[0].zone_id : null
}

output "private_hosted_zone_name" {
  description = "Name of the Private Hosted Zone"
  value       = var.enable_private_hosted_zone ? aws_route53_zone.private[0].name : null
}

# -----------------------------------------------------------------------------
# Network Firewall Outputs
# -----------------------------------------------------------------------------
output "network_firewall_id" {
  description = "ID of the Network Firewall"
  value       = var.enable_network_firewall ? aws_networkfirewall_firewall.main[0].id : null
}

output "network_firewall_arn" {
  description = "ARN of the Network Firewall"
  value       = var.enable_network_firewall ? aws_networkfirewall_firewall.main[0].arn : null
}

output "network_firewall_status" {
  description = "Status of the Network Firewall"
  value       = var.enable_network_firewall ? aws_networkfirewall_firewall.main[0].firewall_status : null
}

output "firewall_subnet_ids" {
  description = "List of Firewall subnet IDs"
  value       = aws_subnet.firewall[*].id
}
