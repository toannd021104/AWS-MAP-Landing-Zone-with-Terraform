# =============================================================================
# AWS Network Firewall - Centralized Traffic Inspection
# =============================================================================
# Reference: AWS Whitepaper - Building Scalable and Secure Multi-VPC Network
# Network Firewall provides stateful inspection and intrusion detection
# =============================================================================

# -----------------------------------------------------------------------------
# Firewall Subnets (dedicated subnets for Network Firewall)
# -----------------------------------------------------------------------------
resource "aws_subnet" "firewall" {
  count = var.enable_network_firewall ? length(var.availability_zones) : 0

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 6, 48 + count.index)  # /22 subnets
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-firewall-${var.availability_zones[count.index]}"
    Tier = "Firewall"
  })
}

# -----------------------------------------------------------------------------
# Network Firewall Rule Group - Stateless
# -----------------------------------------------------------------------------
resource "aws_networkfirewall_rule_group" "stateless" {
  count = var.enable_network_firewall ? 1 : 0

  capacity = 100
  name     = "${local.name_prefix}-stateless-rules"
  type     = "STATELESS"

  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        # Allow established connections
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:forward_to_sfe"]
            match_attributes {
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-stateless-rules"
  })
}

# -----------------------------------------------------------------------------
# Network Firewall Rule Group - Stateful
# -----------------------------------------------------------------------------
resource "aws_networkfirewall_rule_group" "stateful" {
  count = var.enable_network_firewall ? 1 : 0

  capacity = 100
  name     = "${local.name_prefix}-stateful-rules"
  type     = "STATEFUL"

  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [var.vpc_cidr]
        }
      }
    }

    rules_source {
      rules_string = <<EOF
# Block known malicious domains
drop http any any -> any any (msg:"Block malicious domains"; http.host; content:"malware"; nocase; sid:1; rev:1;)
drop http any any -> any any (msg:"Block crypto mining"; http.host; content:"coinhive"; nocase; sid:2; rev:1;)

# Allow outbound HTTPS
pass tls $HOME_NET any -> any 443 (msg:"Allow HTTPS"; sid:100; rev:1;)

# Allow outbound HTTP (for package updates, etc.)
pass http $HOME_NET any -> any 80 (msg:"Allow HTTP"; sid:101; rev:1;)

# Allow DNS
pass udp $HOME_NET any -> any 53 (msg:"Allow DNS UDP"; sid:102; rev:1;)
pass tcp $HOME_NET any -> any 53 (msg:"Allow DNS TCP"; sid:103; rev:1;)

# Allow NTP
pass udp $HOME_NET any -> any 123 (msg:"Allow NTP"; sid:104; rev:1;)
EOF
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-stateful-rules"
  })
}

# -----------------------------------------------------------------------------
# Network Firewall Policy
# -----------------------------------------------------------------------------
resource "aws_networkfirewall_firewall_policy" "main" {
  count = var.enable_network_firewall ? 1 : 0

  name = "${local.name_prefix}-firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.stateless[0].arn
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.stateful[0].arn
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-firewall-policy"
  })
}

# -----------------------------------------------------------------------------
# Network Firewall
# -----------------------------------------------------------------------------
resource "aws_networkfirewall_firewall" "main" {
  count = var.enable_network_firewall ? 1 : 0

  name                = "${local.name_prefix}-network-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main[0].arn
  vpc_id              = aws_vpc.main.id

  dynamic "subnet_mapping" {
    for_each = aws_subnet.firewall
    content {
      subnet_id = subnet_mapping.value.id
    }
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-network-firewall"
  })
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group for Network Firewall
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "network_firewall" {
  count = var.enable_network_firewall ? 1 : 0

  name              = "/aws/network-firewall/${local.name_prefix}"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-network-firewall-logs"
  })
}

# -----------------------------------------------------------------------------
# Network Firewall Logging Configuration
# -----------------------------------------------------------------------------
resource "aws_networkfirewall_logging_configuration" "main" {
  count = var.enable_network_firewall ? 1 : 0

  firewall_arn = aws_networkfirewall_firewall.main[0].arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.network_firewall[0].name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }

    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.network_firewall[0].name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
}
