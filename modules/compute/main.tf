# =============================================================================
# Compute Module - Migrated Workloads from vCenter
# =============================================================================
# This module represents workloads migrated from VMware vCenter to AWS
# using AWS Application Migration Service (MGN) or VM Import/Export
# =============================================================================

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -----------------------------------------------------------------------------
# Migrated Web Servers (from vCenter)
# -----------------------------------------------------------------------------
resource "aws_instance" "web" {
  count = var.web_server_count

  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type          = var.web_instance_type
  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = var.instance_profile_name

  root_block_device {
    volume_size           = var.web_root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Migrated from vCenter: ${var.vcenter_source_vms[count.index % length(var.vcenter_source_vms)].name}
    hostnamectl set-hostname ${local.name_prefix}-web-${count.index + 1}

    # Install web server
    dnf install -y httpd
    systemctl enable httpd
    systemctl start httpd

    # Create landing page
    cat > /var/www/html/index.html << 'HTML'
    <!DOCTYPE html>
    <html>
    <head><title>AWS MAP Migration</title></head>
    <body>
    <h1>Migrated from vCenter to AWS</h1>
    <p>Server: ${local.name_prefix}-web-${count.index + 1}</p>
    <p>Source VM: ${var.vcenter_source_vms[count.index % length(var.vcenter_source_vms)].name}</p>
    <p>Migration Program: AWS MAP</p>
    </body>
    </html>
    HTML
  EOF
  )

  tags = merge(var.tags, {
    Name              = "${local.name_prefix}-web-${count.index + 1}"
    Role              = "WebServer"
    MigrationSource   = "vCenter"
    SourceVM          = var.vcenter_source_vms[count.index % length(var.vcenter_source_vms)].name
    SourceDatacenter  = var.vcenter_source_vms[count.index % length(var.vcenter_source_vms)].datacenter
  })

  lifecycle {
    ignore_changes = [ami]
  }
}

# -----------------------------------------------------------------------------
# Migrated Application Servers (from vCenter)
# -----------------------------------------------------------------------------
resource "aws_instance" "app" {
  count = var.app_server_count

  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type          = var.app_instance_type
  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = var.instance_profile_name

  root_block_device {
    volume_size           = var.app_root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Migrated from vCenter: ${var.vcenter_source_vms[count.index % length(var.vcenter_source_vms)].name}
    hostnamectl set-hostname ${local.name_prefix}-app-${count.index + 1}

    # Install Java runtime (typical app server)
    dnf install -y java-17-amazon-corretto
  EOF
  )

  tags = merge(var.tags, {
    Name              = "${local.name_prefix}-app-${count.index + 1}"
    Role              = "AppServer"
    MigrationSource   = "vCenter"
    SourceVM          = var.vcenter_source_vms[count.index % length(var.vcenter_source_vms)].name
    SourceDatacenter  = var.vcenter_source_vms[count.index % length(var.vcenter_source_vms)].datacenter
  })

  lifecycle {
    ignore_changes = [ami]
  }
}

# -----------------------------------------------------------------------------
# Security Groups
# -----------------------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-migrated-web-sg"
  description = "Security group for migrated web servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = var.alb_security_group_ids
  }

  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = var.alb_security_group_ids
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-migrated-web-sg"
  })
}

resource "aws_security_group" "app" {
  name        = "${local.name_prefix}-migrated-app-sg"
  description = "Security group for migrated application servers"
  vpc_id      = var.vpc_id

  ingress {
    description     = "App port from web servers"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-migrated-app-sg"
  })
}

# -----------------------------------------------------------------------------
# Application Load Balancer for Web Tier
# -----------------------------------------------------------------------------
resource "aws_lb" "web" {
  count = var.create_alb ? 1 : 0

  name               = "${local.name_prefix}-web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_group_ids
  subnets            = var.public_subnet_ids

  enable_deletion_protection = var.environment == "prod" ? true : false

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-web-alb"
  })
}

resource "aws_lb_target_group" "web" {
  count = var.create_alb ? 1 : 0

  name     = "${local.name_prefix}-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-web-tg"
  })
}

resource "aws_lb_target_group_attachment" "web" {
  count = var.create_alb ? var.web_server_count : 0

  target_group_arn = aws_lb_target_group.web[0].arn
  target_id        = aws_instance.web[count.index].id
  port             = 80
}

resource "aws_lb_listener" "web_http" {
  count = var.create_alb ? 1 : 0

  load_balancer_arn = aws_lb.web[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web[0].arn
  }

  tags = var.tags
}
