# =============================================================================
# Route 53 - Private Hosted Zone for Internal DNS
# =============================================================================
# Reference: AWS Whitepaper - Building Scalable and Secure Multi-VPC Network
# Private Hosted Zone enables internal DNS resolution within VPC
# =============================================================================

# -----------------------------------------------------------------------------
# Private Hosted Zone
# -----------------------------------------------------------------------------
resource "aws_route53_zone" "private" {
  count = var.enable_private_hosted_zone ? 1 : 0

  name    = var.private_domain_name
  comment = "Private hosted zone for ${local.name_prefix}"

  vpc {
    vpc_id = aws_vpc.main.id
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-private-zone"
  })

  lifecycle {
    ignore_changes = [vpc]
  }
}

# -----------------------------------------------------------------------------
# Default DNS Records
# -----------------------------------------------------------------------------

# Record for internal services
resource "aws_route53_record" "internal" {
  count = var.enable_private_hosted_zone ? 1 : 0

  zone_id = aws_route53_zone.private[0].zone_id
  name    = "internal.${var.private_domain_name}"
  type    = "A"
  ttl     = 300
  records = ["10.0.0.1"]  # Placeholder - update with actual internal IP
}

# -----------------------------------------------------------------------------
# Route 53 Resolver (for hybrid DNS)
# -----------------------------------------------------------------------------

# Inbound Resolver Endpoint - for on-premises to resolve AWS DNS
resource "aws_route53_resolver_endpoint" "inbound" {
  count = var.enable_route53_resolver ? 1 : 0

  name               = "${local.name_prefix}-resolver-inbound"
  direction          = "INBOUND"
  security_group_ids = [aws_security_group.dns_resolver[0].id]

  dynamic "ip_address" {
    for_each = slice(aws_subnet.private[*].id, 0, min(2, length(aws_subnet.private)))
    content {
      subnet_id = ip_address.value
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-resolver-inbound"
  })
}

# Outbound Resolver Endpoint - for AWS to resolve on-premises DNS
resource "aws_route53_resolver_endpoint" "outbound" {
  count = var.enable_route53_resolver ? 1 : 0

  name               = "${local.name_prefix}-resolver-outbound"
  direction          = "OUTBOUND"
  security_group_ids = [aws_security_group.dns_resolver[0].id]

  dynamic "ip_address" {
    for_each = slice(aws_subnet.private[*].id, 0, min(2, length(aws_subnet.private)))
    content {
      subnet_id = ip_address.value
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-resolver-outbound"
  })
}

# Security Group for DNS Resolver
resource "aws_security_group" "dns_resolver" {
  count = var.enable_route53_resolver ? 1 : 0

  name        = "${local.name_prefix}-dns-resolver-sg"
  description = "Security group for Route 53 Resolver"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "DNS TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "DNS UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-dns-resolver-sg"
  })
}

# -----------------------------------------------------------------------------
# Resolver Rules (forward queries to on-premises DNS)
# -----------------------------------------------------------------------------
resource "aws_route53_resolver_rule" "forward" {
  count = var.enable_route53_resolver && length(var.onprem_dns_servers) > 0 ? 1 : 0

  name                 = "${local.name_prefix}-forward-rule"
  domain_name          = var.onprem_domain_name
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound[0].id

  dynamic "target_ip" {
    for_each = var.onprem_dns_servers
    content {
      ip   = target_ip.value
      port = 53
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-forward-rule"
  })
}

# Associate rule with VPC
resource "aws_route53_resolver_rule_association" "forward" {
  count = var.enable_route53_resolver && length(var.onprem_dns_servers) > 0 ? 1 : 0

  resolver_rule_id = aws_route53_resolver_rule.forward[0].id
  vpc_id           = aws_vpc.main.id
}
