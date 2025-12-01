# =============================================================================
# AWS Application Migration Service (MGN) Module
# =============================================================================
# Lift-and-shift migration from VMware vCenter to AWS Landing Zone
# https://docs.aws.amazon.com/mgn/latest/ug/what-is-application-migration-service.html
#
# Note: AWS MGN has limited Terraform support. This module creates:
# - IAM Roles for MGN agents and replication
# - Security Groups for replication and target instances
# - CloudWatch Logs and SNS notifications
#
# MGN service initialization and source server registration must be done via:
# - AWS Console
# - AWS CLI
# - scripts/mgn-init.sh (included)
# =============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# IAM Role for MGN Service (Service-linked role - created automatically by MGN)
# Note: Service-linked role is auto-created when MGN is initialized via console/CLI
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# IAM Role for MGN Replication Agent (installed on source servers)
# -----------------------------------------------------------------------------
resource "aws_iam_role" "mgn_agent" {
  count = var.enable_mgn ? 1 : 0

  name = "${local.name_prefix}-mgn-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "mgn.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Custom policy for MGN Agent (if AWS managed policy doesn't exist)
resource "aws_iam_role_policy" "mgn_agent" {
  count = var.enable_mgn ? 1 : 0

  name = "${local.name_prefix}-mgn-agent-policy"
  role = aws_iam_role.mgn_agent[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "mgn:SendAgentMetricsForMgn",
          "mgn:SendAgentLogsForMgn",
          "mgn:SendClientLogsForMgn",
          "mgn:GetAgentInstallationAssetsForMgn",
          "mgn:GetAgentCommandForMgn",
          "mgn:GetAgentConfirmedResumeInfoForMgn",
          "mgn:GetAgentReplicationInfoForMgn",
          "mgn:GetAgentRuntimeConfigurationForMgn",
          "mgn:GetAgentSnapshotCreditsForMgn",
          "mgn:RegisterAgentForMgn",
          "mgn:UpdateAgentReplicationInfoForMgn",
          "mgn:UpdateAgentSourcePropertiesForMgn",
          "mgn:UpdateAgentBacklogForMgn",
          "mgn:UpdateAgentConversionInfoForMgn"
        ]
        Resource = "*"
      }
    ]
  })
}

# -----------------------------------------------------------------------------
# IAM Role for MGN Replication Servers
# -----------------------------------------------------------------------------
resource "aws_iam_role" "mgn_replication" {
  count = var.enable_mgn ? 1 : 0

  name = "${local.name_prefix}-mgn-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "mgn_replication" {
  count = var.enable_mgn ? 1 : 0

  role       = aws_iam_role.mgn_replication[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSApplicationMigrationReplicationServerPolicy"
}

resource "aws_iam_instance_profile" "mgn_replication" {
  count = var.enable_mgn ? 1 : 0

  name = "${local.name_prefix}-mgn-replication-profile"
  role = aws_iam_role.mgn_replication[0].name

  tags = var.tags
}

# -----------------------------------------------------------------------------
# IAM Role for MGN Conversion Server
# -----------------------------------------------------------------------------
resource "aws_iam_role" "mgn_conversion" {
  count = var.enable_mgn ? 1 : 0

  name = "${local.name_prefix}-mgn-conversion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "mgn_conversion" {
  count = var.enable_mgn ? 1 : 0

  role       = aws_iam_role.mgn_conversion[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSApplicationMigrationConversionServerPolicy"
}

resource "aws_iam_instance_profile" "mgn_conversion" {
  count = var.enable_mgn ? 1 : 0

  name = "${local.name_prefix}-mgn-conversion-profile"
  role = aws_iam_role.mgn_conversion[0].name

  tags = var.tags
}

# -----------------------------------------------------------------------------
# IAM User for MGN Agent Installation (on source servers)
# -----------------------------------------------------------------------------
resource "aws_iam_user" "mgn_agent_installer" {
  count = var.enable_mgn && var.create_agent_user ? 1 : 0

  name = "${local.name_prefix}-mgn-agent-installer"
  path = "/mgn/"

  tags = var.tags
}

resource "aws_iam_user_policy_attachment" "mgn_agent_installer" {
  count = var.enable_mgn && var.create_agent_user ? 1 : 0

  user       = aws_iam_user.mgn_agent_installer[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSApplicationMigrationAgentInstallationPolicy"
}

# -----------------------------------------------------------------------------
# Security Group for MGN Replication Servers
# -----------------------------------------------------------------------------
resource "aws_security_group" "mgn_replication" {
  count = var.enable_mgn && var.create_security_groups ? 1 : 0

  name        = "${local.name_prefix}-mgn-replication-sg"
  description = "Security group for MGN replication servers"
  vpc_id      = var.vpc_id

  # Allow replication traffic from source servers (TCP 1500)
  ingress {
    description = "MGN Agent replication"
    from_port   = 1500
    to_port     = 1500
    protocol    = "tcp"
    cidr_blocks = var.source_cidr_blocks
  }

  # Allow HTTPS for agent communication
  ingress {
    description = "HTTPS for MGN agent"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.source_cidr_blocks
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-mgn-replication-sg"
  })
}

# -----------------------------------------------------------------------------
# Security Group for Migrated Instances (Target)
# -----------------------------------------------------------------------------
resource "aws_security_group" "mgn_target" {
  count = var.enable_mgn && var.create_security_groups ? 1 : 0

  name        = "${local.name_prefix}-mgn-target-sg"
  description = "Security group for migrated instances"
  vpc_id      = var.vpc_id

  # SSH access (from bastion only)
  dynamic "ingress" {
    for_each = length(var.bastion_security_group_ids) > 0 ? [1] : []
    content {
      description     = "SSH from bastion"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      security_groups = var.bastion_security_group_ids
    }
  }

  # HTTP/HTTPS for web servers
  dynamic "ingress" {
    for_each = var.allow_web_traffic && length(var.alb_security_group_ids) > 0 ? [1] : []
    content {
      description     = "HTTP from ALB"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = var.alb_security_group_ids
    }
  }

  dynamic "ingress" {
    for_each = var.allow_web_traffic && length(var.alb_security_group_ids) > 0 ? [1] : []
    content {
      description     = "HTTPS from ALB"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = var.alb_security_group_ids
    }
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-mgn-target-sg"
  })
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group for MGN
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "mgn" {
  count = var.enable_mgn ? 1 : 0

  name              = "/aws/mgn/${local.name_prefix}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-mgn-logs"
  })
}

# -----------------------------------------------------------------------------
# SNS Topic for MGN Notifications
# -----------------------------------------------------------------------------
resource "aws_sns_topic" "mgn_notifications" {
  count = var.enable_mgn && var.enable_notifications ? 1 : 0

  name = "${local.name_prefix}-mgn-notifications"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-mgn-notifications"
  })
}

# -----------------------------------------------------------------------------
# EventBridge Rule for MGN State Changes
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "mgn_state_change" {
  count = var.enable_mgn && var.enable_notifications ? 1 : 0

  name        = "${local.name_prefix}-mgn-state-change"
  description = "Capture MGN source server state changes"

  event_pattern = jsonencode({
    source      = ["aws.mgn"]
    detail-type = ["MGN Source Server State Change"]
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "mgn_sns" {
  count = var.enable_mgn && var.enable_notifications ? 1 : 0

  rule      = aws_cloudwatch_event_rule.mgn_state_change[0].name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.mgn_notifications[0].arn
}

resource "aws_sns_topic_policy" "mgn_notifications" {
  count = var.enable_mgn && var.enable_notifications ? 1 : 0

  arn = aws_sns_topic.mgn_notifications[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventBridge"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.mgn_notifications[0].arn
      }
    ]
  })
}
